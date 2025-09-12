package com.alertas.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alertas.entity.Usuario;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByNombreUsuario(String nombreUsuario);
}
