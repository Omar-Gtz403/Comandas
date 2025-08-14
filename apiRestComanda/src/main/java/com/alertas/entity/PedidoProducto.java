package com.alertas.entity;

import java.math.BigDecimal;

import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MapsId;
import javax.persistence.Table;

@Entity
@Table(name = "pedido_producto")
public class PedidoProducto {
	@EmbeddedId
	private PedidoProductoId id = new PedidoProductoId();

	@ManyToOne
	@MapsId("idPedido")
	@JoinColumn(name = "id_pedido")
	private Pedido pedido;

	@ManyToOne
	@MapsId("idProducto")
	@JoinColumn(name = "id_producto")
	private Producto producto;

	private Integer cantidad;
	private BigDecimal precioUnitario;

	// Getters y Setters
	public PedidoProductoId getId() {
		return id;
	}

	public void setId(PedidoProductoId id) {
		this.id = id;
	}

	public Pedido getPedido() {
		return pedido;
	}

	public void setPedido(Pedido pedido) {
		this.pedido = pedido;
	}

	public Producto getProducto() {
		return producto;
	}

	public void setProducto(Producto producto) {
		this.producto = producto;
	}

	public Integer getCantidad() {
		return cantidad;
	}

	public void setCantidad(Integer cantidad) {
		this.cantidad = cantidad;
	}

	public BigDecimal getPrecioUnitario() {
		return precioUnitario;
	}

	public void setPrecioUnitario(BigDecimal precioUnitario) {
		this.precioUnitario = precioUnitario;
	}

}
