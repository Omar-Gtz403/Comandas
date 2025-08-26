package com.alertas.service;

import com.alertas.entity.Producto;
import com.alertas.repository.ProductoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductoService {

	private final ProductoRepository productoRepository;

	public ProductoService(ProductoRepository productoRepository) {
		this.productoRepository = productoRepository;
	}

	public List<Producto> listarTodos() {
		return productoRepository.findAll();
	}
}
