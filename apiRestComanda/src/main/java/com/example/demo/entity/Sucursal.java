package com.example.demo.entity;

import javax.persistence.*;

@Entity
@Table(name = "tbl_sucursales")
public class Sucursal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_Sucursal;

    private String nombre_Sucursal;
    private String direccion_Sucursal;

    // Getters y setters
    public Long getId_Sucursal() { return id_Sucursal; }
    public void setId_Sucursal(Long id_Sucursal) { this.id_Sucursal = id_Sucursal; }
    public String getNombre_Sucursal() { return nombre_Sucursal; }
    public void setNombre_Sucursal(String nombre_Sucursal) { this.nombre_Sucursal = nombre_Sucursal; }
    public String getDireccion_Sucursal() { return direccion_Sucursal; }
    public void setDireccion_Sucursal(String direccion_Sucursal) { this.direccion_Sucursal = direccion_Sucursal; }
}
