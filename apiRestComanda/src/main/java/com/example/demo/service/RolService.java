package com.example.demo.service;

import org.springframework.stereotype.Service;
import com.example.demo.entity.*;
import com.example.demo.repository.*;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RolService {

    private final RolRepository rolRepository;
    private final PermisoRepository permisoRepository;

    public RolService(RolRepository rolRepository, PermisoRepository permisoRepository) {
        this.rolRepository = rolRepository;
        this.permisoRepository = permisoRepository;
    }

    public Rol crearRol(Rol rol, List<Long> permisosIds) {
        if (rolRepository.existsByNombre(rol.getNombre())) {
            throw new RuntimeException("Ya existe un rol con ese nombre");
        }

        // Crear RolPermisos
        List<RolPermiso> rolPermisos = permisosIds.stream().map(id -> {
            Permiso permiso = permisoRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Permiso no encontrado: " + id));
            return new RolPermiso(rol, permiso);
        }).collect(Collectors.toList());

        rol.setRolPermisos(rolPermisos);
        return rolRepository.save(rol);
    }

    public List<Rol> listarRoles() {
        return rolRepository.findAll();
    }
}
