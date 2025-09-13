package com.example.demo.entity;

import javax.persistence.*;

@Entity
@Table(name = "tbl_sucursales")
public class Sucursal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_Sucursales")
    private Long id;

    @Column(name = "nombre_Sucursal")
    private String nombre;

    @Column(name = "direccion_Sucursal")
    private String direccion;

    @Column(name = "clave_Sucursal")
    private String clave;

    public Sucursal() {
    }

    public Sucursal(Long id, String nombre, String direccion, String clave) {
        this.id = id;
        this.nombre = nombre;
        this.direccion = direccion;
        this.clave = clave;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getClave() {
        return clave;
    }

    public void setClave(String clave) {
        this.clave = clave;
    }


    @Override
    public String toString() {
        return "Sucursal{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", direccion='" + direccion + '\'' +
                ", clave='" + clave + '\'' +
                '}';
    }
}
