package com.alertas.entity;

import java.io.Serializable;

import javax.persistence.Embeddable;

@Embeddable
public class PedidoProductoId implements Serializable {
	private Integer idPedido;
	private Integer idProducto;

	// equals() y hashCode()
}
