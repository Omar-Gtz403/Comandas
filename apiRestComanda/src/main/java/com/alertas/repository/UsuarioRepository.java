package com.alertas.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alertas.entity.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
}