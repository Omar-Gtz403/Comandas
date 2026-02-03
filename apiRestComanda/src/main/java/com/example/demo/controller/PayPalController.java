package com.example.demo.controller;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.dto.GuardarOrderDTO;
import com.example.demo.dto.PagoRequest;
import com.example.demo.entity.Venta;
import com.example.demo.service.PayPalHttpService;
import com.example.demo.service.VentaService;

@RestController
@RequestMapping("/api/paypal")
public class PayPalController {

    @Autowired
    private PayPalHttpService payPalHttpService;

    @Autowired
    private VentaService ventaService;

    @PostMapping("/confirmar-pago")
    public ResponseEntity<?> confirmarPago(@RequestBody PagoRequest request) {

        try {
            // 1️⃣ Consultar la orden REAL en PayPal
            Map<String, Object> order =
                    payPalHttpService.obtenerOrden(request.getOrderId());

            if (order == null || !"COMPLETED".equals(order.get("status"))) {
                return ResponseEntity.badRequest()
                        .body("Pago no completado en PayPal");
            }

            // 2️⃣ Obtener la venta por folio
            Venta venta = ventaService.obtenerVentaPorFolio(request.getFolio());

            if (venta.getStatus() == 1) {
                return ResponseEntity.badRequest()
                        .body("La venta ya fue pagada");
            }

            // 3️⃣ Obtener purchase_units[0]
            List<Map<String, Object>> purchaseUnits =
                    (List<Map<String, Object>>) order.get("purchase_units");

            Map<String, Object> purchaseUnit = purchaseUnits.get(0);

            // 4️⃣ Obtener payments.captures[0]
            Map<String, Object> payments =
                    (Map<String, Object>) purchaseUnit.get("payments");

            List<Map<String, Object>> captures =
                    (List<Map<String, Object>>) payments.get("captures");

            Map<String, Object> capture = captures.get(0);

            // 5️⃣ Validar que el capture esté COMPLETED
            if (!"COMPLETED".equals(capture.get("status"))) {
                return ResponseEntity.badRequest()
                        .body("Pago no capturado correctamente");
            }

            // 6️⃣ Obtener MONTO REAL cobrado
            Map<String, Object> amount =
                    (Map<String, Object>) capture.get("amount");

            BigDecimal totalPaypal =
                    new BigDecimal(amount.get("value").toString())
                            .setScale(2, RoundingMode.HALF_UP);

            BigDecimal totalVenta =
                    BigDecimal.valueOf(venta.getTotal())
                            .setScale(2, RoundingMode.HALF_UP);

            if (totalVenta.compareTo(totalPaypal) != 0) {
                return ResponseEntity.badRequest()
                        .body("El monto pagado no coincide");
            }


         // 7️⃣ Guardar CAPTURE ID
            String captureId = (String) capture.get("id");
            venta.setPaypalCaptureId(captureId);

            // 8️⃣ Marcar venta como pagada
            venta.setStatus(1);
            ventaService.guardar(venta);

            return ResponseEntity.ok("Pago confirmado correctamente");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al validar el pago");
        }
    }
    @PostMapping("/guardar-order")
    public ResponseEntity<?> guardarOrder(@RequestBody GuardarOrderDTO dto) {

        Venta venta = ventaService.obtenerVentaPorFolio(dto.getFolio());

        if (venta.getStatus() != 0) {
            return ResponseEntity.badRequest().body("La venta ya fue pagada");
        }

        venta.setPaypalOrderId(dto.getOrderId());
        ventaService.guardar(venta);

        return ResponseEntity.ok().build();
    }
    @PostMapping("/refund")
    public ResponseEntity<?> refund(@RequestBody Map<String, String> body) {

        String folio = body.get("folio");

        Venta venta = ventaService.obtenerVentaPorFolio(folio);

        if (venta.getStatus() != 1) {
            return ResponseEntity.badRequest()
                    .body("La venta no está pagada");
        }

        payPalHttpService.reembolsarPago(
                venta.getPaypalCaptureId(),
                venta.getTotal()
        );

        venta.setStatus(5); // CANCELADO
        ventaService.guardar(venta);

        return ResponseEntity.ok("Reembolso realizado");
    }

    

}
