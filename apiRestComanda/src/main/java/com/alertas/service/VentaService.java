package com.alertas.service;

import javax.transaction.Transactional;

import org.springframework.stereotype.Service;

import com.alertas.entity.Producto;
import com.alertas.entity.*;
import com.alertas.repository.*;

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
        venta.getDetalles().forEach(detalle -> {
            detalle.setVenta(venta);

            // Buscar producto en BD
            Producto producto = productoRepository.findById(detalle.getCodigoBarras())
                    .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + detalle.getCodigoBarras()));

            // Validar stock (cantidad_existente en BD)
            if (producto.getCantidadExistente() < detalle.getCantidad()) {
                throw new RuntimeException("Stock insuficiente para " + producto.getNombreProducto());
            }

            // Restar stock
            producto.setCantidadExistente(producto.getCantidadExistente() - detalle.getCantidad());

            // Guardar producto actualizado
            productoRepository.save(producto);
        });

        // Guardar venta y devolver con ID generado
        return ventaRepository.save(venta);
    }
}

