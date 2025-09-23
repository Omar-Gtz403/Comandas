package com.example.demo.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "tbl_productos")
public class Producto {

    @Id
    @Column(name = "codigo_barras", length = 50)
    private String codigoBarras;

    @Column(name = "nombre_producto", nullable = false, length = 45)
    private String nombreProducto;
    @Column(nullable = false)
    private Boolean activo = true;
    @Column(length = 45)
    private String proveedor;

    @Column(length = 100, nullable = false)
    private String descripcion;

    @Column(name = "precio_compra", nullable = false)
    private float precioCompra;

    @Column(name = "precio_venta", nullable = false)
    private float precioVenta;

    @Column(name = "stock_min", nullable = false)
    private int stockMin;

    @Column(name = "stock_max", nullable = false)
    private int stockMax;

    @Column(nullable = false, length = 11)
    private String caducidad;

    @Column(name = "cantidad_existente")
    private Float cantidadExistente;

    @Column(nullable = false, length = 250)
    private String img;

    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private Categoria categoria;

    // ===== Getters & Setters =====
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

    public float getPrecioCompra() {
        return precioCompra;
    }

    public void setPrecioCompra(float precioCompra) {
        this.precioCompra = precioCompra;
    }

    public float getPrecioVenta() {
        return precioVenta;
    }

    public void setPrecioVenta(float precioVenta) {
        this.precioVenta = precioVenta;
    }

    public int getStockMin() {
        return stockMin;
    }

    public void setStockMin(int stockMin) {
        this.stockMin = stockMin;
    }

    public int getStockMax() {
        return stockMax;
    }

    public void setStockMax(int stockMax) {
        this.stockMax = stockMax;
    }

    public String getCaducidad() {
        return caducidad;
    }

  
    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }


	public void setCaducidad(String caducidad) {
        this.caducidad = caducidad;
    }

    public Float getCantidadExistente() {
        return cantidadExistente;
    }

    public void setCantidadExistente(Float cantidadExistente) {
        this.cantidadExistente = cantidadExistente;
    }

    public String getImg() {
        return img;
    }

    public void setImg(String img) {
        this.img = img;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }
}