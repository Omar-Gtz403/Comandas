package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.entity.VentaDetalle;

public interface VentaDetalleRepository extends JpaRepository<VentaDetalle, Long> {
}
