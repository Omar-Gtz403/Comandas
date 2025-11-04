package com.example.demo.entity;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonBackReference;

@Entity
@Table(name = "tbl_rol_permisos", uniqueConstraints = @UniqueConstraint(columnNames = { "id_rol", "id_permiso" }))
public class RolPermiso {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name = "id_rol", nullable = false)
	@JsonBackReference
	private Rol rol;

	@ManyToOne
	@JoinColumn(name = "id_permiso", nullable = false)
	private Permiso permiso;

	public RolPermiso() {
	} // ✅ Constructor vacío requerido por JPA

	public RolPermiso(Rol rol, Permiso permiso) {
		this.rol = rol;
		this.permiso = permiso;
	}

	// Getters y Setters
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Rol getRol() {
		return rol;
	}

	public void setRol(Rol rol) {
		this.rol = rol;
	}

	public Permiso getPermiso() {
		return permiso;
	}

	public void setPermiso(Permiso permiso) {
		this.permiso = permiso;
	}
}
