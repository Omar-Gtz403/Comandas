package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.demo.entity.Permiso;

public interface PermisoRepository extends JpaRepository<Permiso, Long> {
    boolean existsByNombre(String nombre); // ✅ esto agrega el método
}
