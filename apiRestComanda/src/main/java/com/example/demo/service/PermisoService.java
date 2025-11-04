package com.example.demo.service;

import org.springframework.stereotype.Service;
import com.example.demo.entity.Permiso;
import com.example.demo.repository.PermisoRepository;

import java.util.List;

@Service
public class PermisoService {

    private final PermisoRepository permisoRepository;

    public PermisoService(PermisoRepository permisoRepository) {
        this.permisoRepository = permisoRepository;
    }

    public List<Permiso> obtenerTodos() {
        return permisoRepository.findAll();
    }

    public Permiso guardar(Permiso permiso) {
        if (permisoRepository.existsByNombre(permiso.getNombre())) {
            throw new RuntimeException("Ya existe un permiso con ese nombre");
        }
        return permisoRepository.save(permiso);
    }

    public Permiso obtenerPorId(Long id) {
        return permisoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Permiso no encontrado"));
    }

    public void eliminar(Long id) {
        permisoRepository.deleteById(id);
    }
}
