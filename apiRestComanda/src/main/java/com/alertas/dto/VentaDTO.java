package com.alertas.dto;

import java.util.List;
import java.util.stream.Collectors;

import com.alertas.entity.Venta;

public class VentaDTO {
	private Long id;
	private Double total;
	private Boolean pagado;
	private List<VentaDetalleDTO> detalles;

	public VentaDTO(Venta venta) {
		this.id = venta.getId();
		this.total = venta.getTotal();
		this.pagado = venta.getPagado();
		this.detalles = venta.getDetalles().stream().map(VentaDetalleDTO::new).collect(Collectors.toList());
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Double getTotal() {
		return total;
	}

	public void setTotal(Double total) {
		this.total = total;
	}

	public Boolean getPagado() {
		return pagado;
	}

	public void setPagado(Boolean pagado) {
		this.pagado = pagado;
	}

	public List<VentaDetalleDTO> getDetalles() {
		return detalles;
	}

	public void setDetalles(List<VentaDetalleDTO> detalles) {
		this.detalles = detalles;
	}

}
