package com.alertas.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "tbl_productos")
public class Producto {

    @Id
    @Column(name = "codigo_barras")
    private String codigoBarras;

    @Column(name = "nombre_producto")
    private String nombreProducto;

    @Column(name = "Proveedor")
    private String proveedor;

    @Column(name = "descripcion")
    private String descripcion;

    @Column(name = "precio_compra")
    private Double precioCompra;

    @Column(name = "precio_venta")
    private Double precioVenta;

    @Column(name = "stock_min")
    private Integer stockMin;

    @Column(name = "stock_max")
    private Integer stockMax;

    @Column(name = "caducidad")
    private String caducidad;

    @Column(name = "cantidad_existente")
    private Double cantidadExistente;

    @Column(name = "img")
    private String img;

	public String getCodigoBarras() {
		return codigoBarras;
	}

	public void setCodigoBarras(String codigoBarras) {
		this.codigoBarras = codigoBarras;
	}

	public String getNombreProducto() {
		return nombreProducto;
	}

	public void setNombreProducto(String nombreProducto) {
		this.nombreProducto = nombreProducto;
	}

	public String getProveedor() {
		return proveedor;
	}

	public void setProveedor(String proveedor) {
		this.proveedor = proveedor;
	}

	public String getDescripcion() {
		return descripcion;
	}

	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}

	public Double getPrecioCompra() {
		return precioCompra;
	}

	public void setPrecioCompra(Double precioCompra) {
		this.precioCompra = precioCompra;
	}

	public Double getPrecioVenta() {
		return precioVenta;
	}

	public void setPrecioVenta(Double precioVenta) {
		this.precioVenta = precioVenta;
	}

	public Integer getStockMin() {
		return stockMin;
	}

	public void setStockMin(Integer stockMin) {
		this.stockMin = stockMin;
	}

	public Integer getStockMax() {
		return stockMax;
	}

	public void setStockMax(Integer stockMax) {
		this.stockMax = stockMax;
	}

	public String getCaducidad() {
		return caducidad;
	}

	public void setCaducidad(String caducidad) {
		this.caducidad = caducidad;
	}

	public Double getCantidadExistente() {
		return cantidadExistente;
	}

	public void setCantidadExistente(Double cantidadExistente) {
		this.cantidadExistente = cantidadExistente;
	}

	public String getImg() {
		return img;
	}

	public void setImg(String img) {
		this.img = img;
	}

    // Getters y Setters
    
}

