package com.example.demo.entity;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "tbl_roles")
public class Rol {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre", nullable = false, unique = true)
    private String nombre;

    @Column(name = "descripcion")
    private String descripcion;

    @OneToMany(mappedBy = "rol", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JsonManagedReference
    private List<RolPermiso> rolPermisos = new ArrayList<>();

    public Rol() {
    }

    public Rol(String nombre, String descripcion) {
        this.nombre = nombre;
        this.descripcion = descripcion;
    }

    // 🔹 Devuelve directamente la lista de permisos
    @JsonIgnoreProperties("rol")
    public List<Permiso> getPermisos() {
        return rolPermisos != null
                ? rolPermisos.stream()
                        .map(RolPermiso::getPermiso)
                        .collect(Collectors.toList())
                : new ArrayList<>();
    }

    // 🔹 Devuelve solo los nombres de los permisos
    public List<String> getPermisosList() {
        return rolPermisos != null
                ? rolPermisos.stream()
                        .map(rp -> rp.getPermiso().getNombre())
                        .collect(Collectors.toList())
                : List.of();
    }

    // Getters y Setters estándar
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

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public List<RolPermiso> getRolPermisos() {
        return rolPermisos;
    }

    public void setRolPermisos(List<RolPermiso> rolPermisos) {
        this.rolPermisos = rolPermisos;
    }
}
