package com.alertas.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "tbl_productos")
public class Producto {

    @Id
    @Column(name = "codigo_barras", length = 50)
    private String codigoBarras;

    @Column(name = "nombre_producto", nullable = false, length = 45)
    private String nombre;

    @Column(nullable = false, length = 100)
    private String descripcion;

    @Column(name = "precio_venta", nullable = false)
    private Double precio;

    @Column(name = "cantidad_existente")
    private Double stock;

 

    // Getters y Setters
    public String getCodigoBarras() { return codigoBarras; }
    public void setCodigoBarras(String codigoBarras) { this.codigoBarras = codigoBarras; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Double getPrecio() { return precio; }
    public void setPrecio(Double precio) { this.precio = precio; }
    public Double getStock() { return stock; }
    public void setStock(Double stock) { this.stock = stock; }

}
