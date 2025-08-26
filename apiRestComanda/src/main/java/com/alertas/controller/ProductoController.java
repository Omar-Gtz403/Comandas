package com.alertas.controller;

import com.alertas.entity.Producto;
import com.alertas.repository.ProductoRepository;
import com.alertas.service.ProductoService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "*")
public class ProductoController {

	private final ProductoService productoService;
	private final ProductoRepository productoRepository;

	// Inyectamos ambos en el constructor
	public ProductoController(ProductoService productoService, ProductoRepository productoRepository) {
		this.productoService = productoService;
		this.productoRepository = productoRepository;
	}

	@GetMapping
	public List<Producto> listar() {
		System.out.println("Se consultó la API /api/productos");
		return productoService.listarTodos();

	}

	@PostMapping
	public Producto crearProducto(@RequestBody Producto producto) {
		return productoRepository.save(producto);
	}
}
