package com.example.demo.controller;

import com.example.demo.entity.Permiso;
import com.example.demo.service.PermisoService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/permisos")
@CrossOrigin(origins = "*") // opcional para permitir peticiones desde frontend
public class PermisoController {

    private final PermisoService permisoService;

    public PermisoController(PermisoService permisoService) {
        this.permisoService = permisoService;
    }

    @GetMapping
    public List<Permiso> obtenerTodos() {
        return permisoService.obtenerTodos();
    }

    @PostMapping
    public Permiso crear(@RequestBody Permiso permiso) {
        return permisoService.guardar(permiso);
    }

    @GetMapping("/{id}")
    public Permiso obtenerPorId(@PathVariable Long id) {
        return permisoService.obtenerPorId(id);
    }

    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable Long id) {
        permisoService.eliminar(id);
    }
}
