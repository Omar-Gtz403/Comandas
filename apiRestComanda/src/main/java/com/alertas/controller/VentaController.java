package com.alertas.controller;



import com.alertas.entity.Venta;
import com.alertas.repository.VentaRepository;
import com.alertas.service.VentaService;

import java.util.List;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ventas")
@CrossOrigin(origins = "*")
public class VentaController {

    private final VentaService ventaService;
    private final VentaRepository ventaRepository;
    

    public VentaController(VentaService ventaService, VentaRepository ventaRepository) {
        this.ventaService = ventaService;
        this.ventaRepository = ventaRepository;
    }
    @GetMapping
    public List<Venta> listarVentas() {
        return ventaRepository.findAll();
    }
    @PutMapping("/{id}/pagar")
    public Venta pagarVenta(@PathVariable Long id) {
        return ventaService.marcarComoPagada(id);
    }
    @PostMapping
    public Venta registrarVenta(@RequestBody Venta venta) {
        return ventaService.registrarVenta(venta);
    }
}
