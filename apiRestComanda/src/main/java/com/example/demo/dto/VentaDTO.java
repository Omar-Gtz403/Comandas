package com.example.demo.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import com.example.demo.entity.Venta;

public class VentaDTO {
    private Long id;
    private String folio; 
    private Double total;
    private Boolean pagado;
    private Integer status;
    private LocalDateTime fecha; // 👈 Agregar fecha
    private List<VentaDetalleDTO> detalles;

    public VentaDTO(Venta venta) {
        this.id = venta.getId();
        this.folio = venta.getFolio();
        this.total = venta.getTotal();
        this.status = venta.getStatus();
        this.fecha = venta.getFecha(); // 👈 Aquí asignamos la fecha
        this.detalles = venta.getDetalles()
                             .stream()
                             .map(VentaDetalleDTO::new)
                             .collect(Collectors.toList());
    }

    // getters & setters...
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFolio() { return folio; }
    public void setFolio(String folio) { this.folio = folio; }

    public Double getTotal() { return total; }
    public void setTotal(Double total) { this.total = total; }

    public Boolean getPagado() { return pagado; }
    public void setPagado(Boolean pagado) { this.pagado = pagado; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }

    public List<VentaDetalleDTO> getDetalles() { return detalles; }
    public void setDetalles(List<VentaDetalleDTO> detalles) { this.detalles = detalles; }
}
