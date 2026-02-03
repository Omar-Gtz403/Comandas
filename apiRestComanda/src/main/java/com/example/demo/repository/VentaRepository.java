package com.example.demo.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.entity.Venta;

public interface VentaRepository extends JpaRepository<Venta, Long> {

    Optional<Venta> findByFolio(String folio);

    Optional<Venta> findByPaypalOrderId(String paypalOrderId);

    List<Venta> findByStatusAndFechaBefore(Integer status, LocalDateTime fecha);
}
