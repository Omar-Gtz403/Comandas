package com.example.demo.controller;

import org.springframework.web.bind.annotation.*;
import com.example.demo.entity.Rol;
import com.example.demo.dto.RolRequest;
import com.example.demo.service.RolService;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
@CrossOrigin(origins = "*")
public class RolController {

    private final RolService rolService;

    public RolController(RolService rolService) {
        this.rolService = rolService;
    }

    @PostMapping
    public Rol crearRol(@RequestBody RolRequest rolRequest) {
        Rol rol = new Rol(rolRequest.getNombre(), rolRequest.getDescripcion());
        return rolService.crearRol(rol, rolRequest.getPermisosIds());
    }

    @GetMapping
    public List<Rol> listarRoles() {
        return rolService.listarRoles();
    }
}
