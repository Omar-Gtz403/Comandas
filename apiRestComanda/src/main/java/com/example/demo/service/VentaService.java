package com.example.demo.service;

import java.util.List;
import java.util.stream.Collectors;

import javax.persistence.Column;
import javax.transaction.Transactional;

import org.springframework.stereotype.Service;

import com.example.demo.dto.*;
import com.example.demo.entity.Producto;
import com.example.demo.entity.Venta;
import com.example.demo.entity.VentaDetalle;
import com.example.demo.repository.ProductoRepository;
import com.example.demo.repository.VentaRepository;

@Service
public class VentaService {

	private final VentaRepository ventaRepository;
	private final ProductoRepository productoRepository;

	public VentaService(VentaRepository ventaRepository, ProductoRepository productoRepository) {
		this.ventaRepository = ventaRepository;
		this.productoRepository = productoRepository;
	}
	@Column(nullable = false)
	private int status = 0;
	@Transactional
	public Venta registrarVenta(Venta venta) {
		for (VentaDetalle detalle : venta.getDetalles()) {
			detalle.setVenta(venta);

			Producto producto = productoRepository.findById(detalle.getCodigoBarras())
					.orElseThrow(() -> new RuntimeException("Producto no encontrado: " + detalle.getCodigoBarras()));

			if (producto.getCantidadExistente() < detalle.getCantidad()) {
				throw new RuntimeException("Stock insuficiente para " + producto.getNombreProducto());
			}

			producto.setCantidadExistente(producto.getCantidadExistente() - detalle.getCantidad());
			productoRepository.save(producto);
		}
		return ventaRepository.save(venta);
	}

	@Transactional
	public Venta marcarComoPagada(Long id) {
	    Venta venta = ventaRepository.findById(id)
	        .orElseThrow(() -> new RuntimeException("Venta no encontrada con ID: " + id));

	    venta.setStatus(1); // ✅ PAGADO
	    return ventaRepository.save(venta);
	}


	// ✅ Nuevo método para traer detalles como DTO
	public List<VentaDetalleDTO> obtenerDetalles(Long ventaId) {
		Venta venta = ventaRepository.findById(ventaId)
				.orElseThrow(() -> new RuntimeException("Venta no encontrada con ID: " + ventaId));
		return venta.getDetalles().stream().map(VentaDetalleDTO::new).collect(Collectors.toList());
	}
	public Venta obtenerVentaPorFolio(String folio) {
	    return ventaRepository.findByFolio(folio)
	            .orElseThrow(() -> new RuntimeException("Venta no encontrada con folio: " + folio));
	}
	public List<Venta> listarVentas() {
		return ventaRepository.findAll();
	}

	public List<VentaDTO> listarVentasDTO() {
		return ventaRepository.findAll().stream().map(VentaDTO::new).collect(Collectors.toList());
	}
	public Venta obtenerVentaPorId(Long id) {
	    return ventaRepository.findById(id)
	            .orElseThrow(() -> new RuntimeException("Venta no encontrada con ID: " + id));
	}

	@Transactional
	public Venta actualizarStatus(Long id, Integer nuevoStatus) {
	    Venta venta = ventaRepository.findById(id)
	            .orElseThrow(() -> new RuntimeException("Venta no encontrada con ID: " + id));
	    venta.setStatus(nuevoStatus);
	    return ventaRepository.save(venta);
	}


}
