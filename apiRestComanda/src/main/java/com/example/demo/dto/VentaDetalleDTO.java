package com.example.demo.dto;

import com.example.demo.entity.VentaDetalle;

public class VentaDetalleDTO {

	private String nombreProducto;
	private Integer cantidad;
	private Double precioUnitario;

	public VentaDetalleDTO(VentaDetalle detalle) {
		this.nombreProducto = detalle.getProducto() != null ? detalle.getProducto().getNombreProducto()
				: detalle.getCodigoBarras();
		this.cantidad = detalle.getCantidad();
		this.precioUnitario = detalle.getPrecioUnitario();
	}

	// Getters y setters
	public String getNombreProducto() {
		return nombreProducto;
	}

	public void setNombreProducto(String nombreProducto) {
		this.nombreProducto = nombreProducto;
	}

	public Integer getCantidad() {
		return cantidad;
	}

	public void setCantidad(Integer cantidad) {
		this.cantidad = cantidad;
	}

	public Double getPrecioUnitario() {
		return precioUnitario;
	}

	public void setPrecioUnitario(Double precioUnitario) {
		this.precioUnitario = precioUnitario;
	}
}
