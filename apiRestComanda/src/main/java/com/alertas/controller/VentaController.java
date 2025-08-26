package com.alertas.controller;

import com.alertas.entity.Venta;
import com.alertas.service.VentaService;
import com.alertas.dto.*;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ventas")
@CrossOrigin(origins = "*")
public class VentaController {

	private final VentaService ventaService;

	public VentaController(VentaService ventaService) {
		this.ventaService = ventaService;
	}

	// Listar todas las ventas
	@GetMapping
	public List<VentaDTO> listarVentas() {
		return ventaService.listarVentas().stream().map(VentaDTO::new).collect(Collectors.toList());
	}
	// Consultar una venta por ID (incluye status)
	@GetMapping("/{id}")
	public Venta obtenerVenta(@PathVariable Long id) {
	    return ventaService.obtenerVentaPorId(id);
	}

	// Actualizar el estatus del pedido
	@PutMapping("/{id}/status")
	public Venta actualizarStatus(@PathVariable Long id, @RequestBody Integer nuevoStatus) {
	    return ventaService.actualizarStatus(id, nuevoStatus);
	}

	// Marcar venta como pagada
	@PutMapping("/{id}/pagar")
	public Venta pagarVenta(@PathVariable Long id) {
		return ventaService.marcarComoPagada(id);
	}

	// Registrar una nueva venta
	@PostMapping
	public Venta registrarVenta(@RequestBody Venta venta) {
		return ventaService.registrarVenta(venta);
	}

	// ✅ Nuevo endpoint para obtener detalles de una venta con nombres de productos
	@GetMapping("/{id}/detalles")
	public List<VentaDetalleDTO> obtenerDetalles(@PathVariable Long id) {
		return ventaService.obtenerDetalles(id);
	}
}
