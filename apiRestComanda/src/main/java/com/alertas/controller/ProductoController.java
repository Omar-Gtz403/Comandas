package com.alertas.controller;

import com.alertas.entity.Producto;
import com.alertas.repository.ProductoRepository;
import com.alertas.service.ProductoService;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path; 
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
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
	
	@Value("${app.upload.dir}")
	private String uploadDir;

	@PostMapping(consumes = {"multipart/form-data"})
	public Producto crearProductoConImagen(
	        @RequestParam("codigoBarras") String codigoBarras,
	        @RequestParam("nombreProducto") String nombreProducto,
	        @RequestParam("proveedor") String proveedor,
	        @RequestParam("descripcion") String descripcion,
	        @RequestParam("precioCompra") Double precioCompra,
	        @RequestParam("precioVenta") Double precioVenta,
	        @RequestParam("stockMin") Integer stockMin,
	        @RequestParam("stockMax") Integer stockMax,
	        @RequestParam("caducidad") String caducidad,
	        @RequestParam("cantidadExistente") Double cantidadExistente,
	        @RequestParam("file") MultipartFile file
	) throws IOException {

	    // Crear directorio si no existe
	    Path uploadPath = Paths.get(uploadDir);
	    if (!Files.exists(uploadPath)) {
	        Files.createDirectories(uploadPath);
	    }

	    // Guardar archivo
	    String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
	    Path path = uploadPath.resolve(fileName);
	    Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

	    // Crear producto
	    Producto producto = new Producto();
	    producto.setCodigoBarras(codigoBarras);
	    producto.setNombreProducto(nombreProducto);
	    producto.setProveedor(proveedor);
	    producto.setDescripcion(descripcion);
	    producto.setPrecioCompra(precioCompra);
	    producto.setPrecioVenta(precioVenta);
	    producto.setStockMin(stockMin);
	    producto.setStockMax(stockMax);
	    producto.setCaducidad(caducidad);
	    producto.setCantidadExistente(cantidadExistente);

	    // Guardar solo la URL relativa
	    producto.setImg("/uploads/" + fileName);

	    return productoRepository.save(producto);
	}


}
