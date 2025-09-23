package com.example.demo.controller;

import com.example.demo.entity.Producto;
import com.example.demo.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin("*")
public class ProductoController {

    private static final String UPLOAD_DIR = "/var/www/comandasleadto/uploads";
    private static final String BASE_URL = "https://comandasleadto.duckdns.org/uploads/";

    private final ProductoRepository productoRepository;

    @Autowired
    public ProductoController(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    private void eliminarImagenAnterior(String urlImagen) {
        if (urlImagen != null && !urlImagen.isEmpty()) {
            try {
                String filename = urlImagen.substring(urlImagen.lastIndexOf("/") + 1);
                Path filePath = Paths.get(UPLOAD_DIR).resolve(filename);
                Files.deleteIfExists(filePath);
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("⚠ No se pudo eliminar la imagen: " + urlImagen);
            }
        }
    }

    @GetMapping
    public List<Producto> getAll() {
        return productoRepository.findAll();
    }

    @GetMapping("/{codigo}")
    public ResponseEntity<Producto> getById(@PathVariable String codigo) {
        return productoRepository.findById(codigo)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Producto create(@RequestBody Producto producto) {
        // Si no viene el campo activo, lo ponemos en true
        if (producto.getActivo() == null) {
            producto.setActivo(true);
        }
        return productoRepository.save(producto);
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Archivo vacío"));
        }
        try {
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            String originalFilename = file.getOriginalFilename();
            String filename = System.currentTimeMillis() + "_" + originalFilename;
            Path filepath = uploadPath.resolve(filename);

            Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

            String urlImagen = BASE_URL + filename;

            return ResponseEntity.ok(Map.of("url", urlImagen));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error al guardar la imagen"));
        }
    }

    @PutMapping("/{codigo}")
    public ResponseEntity<Producto> update(@PathVariable String codigo, @RequestBody Producto productoDetails) {
        return productoRepository.findById(codigo).map(producto -> {

            // Eliminar imagen anterior si se cambia
            if (producto.getImg() != null &&
                productoDetails.getImg() != null &&
                !producto.getImg().equals(productoDetails.getImg())) {
                eliminarImagenAnterior(producto.getImg());
            }

            producto.setNombreProducto(productoDetails.getNombreProducto());
            producto.setProveedor(productoDetails.getProveedor());
            producto.setDescripcion(productoDetails.getDescripcion());
            producto.setPrecioCompra(productoDetails.getPrecioCompra());
            producto.setPrecioVenta(productoDetails.getPrecioVenta());
            producto.setStockMin(productoDetails.getStockMin());
            producto.setStockMax(productoDetails.getStockMax());
            producto.setCaducidad(productoDetails.getCaducidad());
            producto.setCantidadExistente(productoDetails.getCantidadExistente());

            if (productoDetails.getImg() != null && !productoDetails.getImg().isEmpty()) {
                producto.setImg(productoDetails.getImg());
            }

            producto.setCategoria(productoDetails.getCategoria());

            // Si el frontend no envía activo, mantener el actual
            producto.setActivo(productoDetails.getActivo() != null ? productoDetails.getActivo() : producto.getActivo());

            return ResponseEntity.ok(productoRepository.save(producto));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{codigo}")
    public ResponseEntity<?> delete(@PathVariable String codigo) {
        return productoRepository.findById(codigo).map(producto -> {
            eliminarImagenAnterior(producto.getImg());
            productoRepository.delete(producto);
            return ResponseEntity.noContent().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
