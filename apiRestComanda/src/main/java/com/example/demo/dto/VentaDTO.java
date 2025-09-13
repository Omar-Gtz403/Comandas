package com.example.demo.dto;

import java.util.List;
import java.util.stream.Collectors;

import com.example.demo.entity.Venta;

public class VentaDTO {
    private Long id;
    private Double total;
    private Boolean pagado;
    private Integer status; // 👈 nuevo
    private List<VentaDetalleDTO> detalles;

    public VentaDTO(Venta venta) {
        this.id = venta.getId();
        this.total = venta.getTotal();
        this.pagado = venta.getPagado();
        this.status = venta.getStatus(); // 👈 asignar
        this.detalles = venta.getDetalles()
                             .stream()
                             .map(VentaDetalleDTO::new)
                             .collect(Collectors.toList());
    }

    // Getters y setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Double getTotal() { return total; }
    public void setTotal(Double total) { this.total = total; }

    public Boolean getPagado() { return pagado; }
    public void setPagado(Boolean pagado) { this.pagado = pagado; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public List<VentaDetalleDTO> getDetalles() { return detalles; }
    public void setDetalles(List<VentaDetalleDTO> detalles) { this.detalles = detalles; }
}
