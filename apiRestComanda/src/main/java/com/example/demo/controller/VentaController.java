package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.entity.Venta;
import com.example.demo.repository.VentaRepository;
import com.example.demo.service.VentaService;

import java.util.List;
import java.util.stream.Collectors;

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
	public Venta actualizarStatus(@PathVariable Long id, @RequestBody StatusDTO dto) {
	    return ventaService.actualizarStatus(id, dto.getStatus());
	}


	// Marcar venta como pagada
	@PutMapping("/{id}/pagar")
	public Venta pagarVenta(@PathVariable Long id) {
		return ventaService.marcarComoPagada(id);
	}

	// Registrar nueva venta
	@PostMapping
	public VentaDTO registrarVenta(@RequestBody Venta venta) {
	    Venta nueva = ventaService.registrarVenta(venta);
	    return new VentaDTO(nueva); // devuelve con folio
	}

	// Consultar por folio
	@GetMapping("/folio/{folio}")
	public VentaDTO obtenerPorFolio(@PathVariable String folio) {
	    return new VentaDTO(ventaService.obtenerVentaPorFolio(folio));
	}
	@PutMapping("/folio/{folio}/status")
	public Venta actualizarStatusPorFolio(@PathVariable String folio, @RequestBody StatusDTO dto) {
	    Venta venta = ventaService.obtenerVentaPorFolio(folio);
	    return ventaService.actualizarStatus(venta.getId(), dto.getStatus());
	}
	@GetMapping("/folio/{folio}/detalles")
	public List<VentaDetalleDTO> obtenerDetallesPorFolio(@PathVariable String folio) {
	    Venta venta = ventaService.obtenerVentaPorFolio(folio);
	    return ventaService.obtenerDetalles(venta.getId());
	}
	// ✅ Nuevo endpoint para obtener detalles de una venta con nombres de productos
	@GetMapping("/{id}/detalles")
	public List<VentaDetalleDTO> obtenerDetalles(@PathVariable Long id) {
		return ventaService.obtenerDetalles(id);
	}
}
