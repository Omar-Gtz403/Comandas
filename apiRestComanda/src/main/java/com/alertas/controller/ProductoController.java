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
	@PutMapping("/{codigoBarras}")
	public Producto actualizarProducto(@PathVariable String codigoBarras, @RequestBody Producto producto) {
	    return productoRepository.findById(codigoBarras).map(p -> {
	        p.setNombreProducto(producto.getNombreProducto());
	        p.setProveedor(producto.getProveedor());
	        p.setDescripcion(producto.getDescripcion());
	        p.setPrecioCompra(producto.getPrecioCompra());
	        p.setPrecioVenta(producto.getPrecioVenta());
	        p.setStockMin(producto.getStockMin());
	        p.setStockMax(producto.getStockMax());
	        p.setCaducidad(producto.getCaducidad());
	        p.setCantidadExistente(producto.getCantidadExistente());
	        p.setImg(producto.getImg());
	        return productoRepository.save(p);
	    }).orElseThrow(() -> new RuntimeException("Producto no encontrado con código: " + codigoBarras));
	}

	@DeleteMapping("/{codigoBarras}")
	public void eliminarProducto(@PathVariable String codigoBarras) {
	    if (!productoRepository.existsById(codigoBarras)) {
	        throw new RuntimeException("Producto no encontrado con código: " + codigoBarras);
	    }
	    productoRepository.deleteById(codigoBarras);
	}

}
