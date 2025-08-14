package com.alertas.repository;

import com.alertas.entity.Pedido;
import com.alertas.entity.Producto;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PedidoRepository extends JpaRepository<Pedido, Integer> {
}