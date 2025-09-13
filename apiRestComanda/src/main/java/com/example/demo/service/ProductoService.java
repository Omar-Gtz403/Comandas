package com.example.demo.service;

import com.example.demo.entity.Producto;
import com.example.demo.repository.ProductoRepository;

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
