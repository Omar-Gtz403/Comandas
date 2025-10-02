package com.example.demo.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.repository.CategoriaRepository;
import com.example.demo.entity.Categoria;
import com.example.demo.dto.CategoriaOrdenDTO;

@RestController
@RequestMapping("/api/categorias")
public class CategoriaController {

    private final CategoriaRepository categoriaRepository;

    public CategoriaController(CategoriaRepository categoriaRepository) {
        this.categoriaRepository = categoriaRepository;
    }

    @GetMapping
    public List<Categoria> getAll() {
        // Que siempre devuelva ordenado por "orden"
        return categoriaRepository.findAll()
                .stream()
                .sorted((a, b) -> Integer.compare(a.getOrden(), b.getOrden()))
                .toList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Categoria> getById(@PathVariable Long id) {
        return categoriaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Categoria create(@RequestBody Categoria categoria) {
        return categoriaRepository.save(categoria);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Categoria> update(@PathVariable Long id, @RequestBody Categoria categoriaDetails) {
        return categoriaRepository.findById(id).map(categoria -> {
            categoria.setNombre(categoriaDetails.getNombre());
            categoria.setActivo(categoriaDetails.isActivo());
            categoria.setOrden(categoriaDetails.getOrden());
            return ResponseEntity.ok(categoriaRepository.save(categoria));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/toggle")
    public ResponseEntity<Categoria> toggleActivo(@PathVariable Long id) {
        return categoriaRepository.findById(id).map(categoria -> {
            categoria.setActivo(!categoria.isActivo());
            return ResponseEntity.ok(categoriaRepository.save(categoria));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 🔥 Nuevo endpoint para actualizar orden
    @PutMapping("/orden")
    public ResponseEntity<?> actualizarOrden(@RequestBody List<CategoriaOrdenDTO> categoriasOrden) {
        for (CategoriaOrdenDTO dto : categoriasOrden) {
            categoriaRepository.findById(dto.getId()).ifPresent(categoria -> {
                categoria.setOrden(dto.getOrden());
                categoriaRepository.save(categoria);
            });
        }
        return ResponseEntity.ok("Orden actualizado correctamente");
    }
}
