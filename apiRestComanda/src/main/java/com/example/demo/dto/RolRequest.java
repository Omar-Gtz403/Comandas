package com.example.demo.dto;

import java.util.List;

public class RolRequest {
	private String nombre;
	private String descripcion;
	private List<Long> permisosIds;

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

	public List<Long> getPermisosIds() {
		return permisosIds;
	}

	public void setPermisosIds(List<Long> permisosIds) {
		this.permisosIds = permisosIds;
	}
}
