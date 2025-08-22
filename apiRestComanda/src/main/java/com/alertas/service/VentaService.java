package com.alertas.service;

import javax.transaction.Transactional;

import org.springframework.stereotype.Service;
import com.alertas.entity.Producto;
import com.alertas.entity.Venta;
import com.alertas.entity.VentaDetalle;
import com.alertas.repository.ProductoRepository;
import com.alertas.repository.VentaRepository;

@Service
public class VentaService {

	private final VentaRepository ventaRepository;
	private final ProductoRepository productoRepository;

	public VentaService(VentaRepository ventaRepository, ProductoRepository productoRepository) {
		this.ventaRepository = ventaRepository;
		this.productoRepository = productoRepository;
	}

	@Transactional
	public Venta registrarVenta(Venta venta) {
		// Recorremos cada detalle de la venta
		for (VentaDetalle detalle : venta.getDetalles()) {
			// Relacionar detalle con la venta
			detalle.setVenta(venta);

			// Buscar producto en BD
			Producto producto = productoRepository.findById(detalle.getCodigoBarras())
					.orElseThrow(() -> new RuntimeException("Producto no encontrado: " + detalle.getCodigoBarras()));

			// Validar stock disponible
			if (producto.getCantidadExistente() < detalle.getCantidad()) {
				throw new RuntimeException("Stock insuficiente para " + producto.getNombreProducto());
			}

			// Restar stock
			producto.setCantidadExistente(producto.getCantidadExistente() - detalle.getCantidad());

			// Guardar producto actualizado
			productoRepository.save(producto);
		}

		// Guardar la venta junto con los detalles
		return ventaRepository.save(venta);
	}

	@Transactional
	public Venta marcarComoPagada(Long id) {
		Venta venta = ventaRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("Venta no encontrada con ID: " + id));

		venta.setPagado(true);
		return ventaRepository.save(venta);
	}

}
