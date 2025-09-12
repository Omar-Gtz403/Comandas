package com.alertas.entity;

import javax.persistence.*;

@Entity
@Table(name = "tbl_usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_Usuario")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "id_Sucursal")
    private Sucursal sucursal;

    @Column(name = "nombre_Usuario", unique = true)
    private String nombreUsuario;

    @Column(name = "password")
    private String password;

    @Column(name = "permiso")
    private Integer permiso;

    // 🔹 Constructor vacío
    public Usuario() {}

    // 🔹 Constructor con parámetros
    public Usuario(Long id, Sucursal sucursal, String nombreUsuario, String password, Integer permiso) {
        this.id = id;
        this.sucursal = sucursal;
        this.nombreUsuario = nombreUsuario;
        this.password = password;
        this.permiso = permiso;
    }

    // 🔹 Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Sucursal getSucursal() { return sucursal; }
    public void setSucursal(Sucursal sucursal) { this.sucursal = sucursal; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Integer getPermiso() { return permiso; }
    public void setPermiso(Integer permiso) { this.permiso = permiso; }
}
