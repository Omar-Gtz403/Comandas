package com.example.demo.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.entity.Venta;
import com.example.demo.service.PayPalWebhookService;
import com.example.demo.service.VentaService;

@RestController
@RequestMapping("/api/paypal")
public class PayPalWebhookController {

    @Autowired
    private VentaService ventaService;

    @Autowired
    private PayPalWebhookService webhookService;

    @PostMapping("/webhook")
    public ResponseEntity<?> recibirWebhook(
            @RequestHeader Map<String, String> headers,
            @RequestBody Map<String, Object> payload
    ) {

        // 🔐 VALIDAR FIRMA
        if (!webhookService.validarFirma(headers, payload)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        String eventType = (String) payload.get("event_type");

        if ("PAYMENT.CAPTURE.COMPLETED".equals(eventType)) {

            Map<String, Object> resource =
                    (Map<String, Object>) payload.get("resource");

            Map<String, Object> supplementaryData =
                    (Map<String, Object>) resource.get("supplementary_data");

            Map<String, Object> relatedIds =
                    (Map<String, Object>) supplementaryData.get("related_ids");

            String orderId = (String) relatedIds.get("order_id");

            Venta venta = ventaService.obtenerPorOrderId(orderId);

            ventaService.marcarPagadaSiNoEsta(venta);
        }

        return ResponseEntity.ok().build();
    }
}

