package com.alertas.dto;

import com.alertas.entity.Producto;

public class ProductoDTO {
	private String codigoBarras;
	private String nombreProducto;
	private String descripcion;
	private Double precio;
	private String img;

	public ProductoDTO(Producto producto) {
		this.codigoBarras = producto.getCodigoBarras();
		this.nombreProducto = producto.getNombreProducto();
		this.descripcion = producto.getDescripcion();
		this.precio = producto.getPrecioVenta();
		this.img = producto.getImg();
	}
}
