package com.example.demo.controller;

import org.springframework.web.bind.annotation.*;
import com.example.demo.entity.RolPermiso;
import com.example.demo.service.RolPermisoService;

@RestController
@RequestMapping("/api/rol-permisos")
@CrossOrigin(origins = "*")
public class RolPermisoController {

    private final RolPermisoService rolPermisoService;

    public RolPermisoController(RolPermisoService rolPermisoService) {
        this.rolPermisoService = rolPermisoService;
    }

    @PostMapping
    public RolPermiso asignarPermiso(@RequestParam Long idRol, @RequestParam Long idPermiso) {
        return rolPermisoService.asignarPermiso(idRol, idPermiso);
    }
}
