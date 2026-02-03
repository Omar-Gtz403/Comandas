package com.example.demo.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.PrePersist;
import javax.persistence.Table;


@Entity
@Table(name = "tbl_ventas")
public class Venta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String folio; // 👈 Folio único

    @Column(nullable = false, updatable = false, insertable = false,
            columnDefinition = "timestamp default current_timestamp")
    private LocalDateTime fecha;

    private Double total;
    @Column(name = "paypal_order_id", unique = true)
    private String paypalOrderId;
    @Column(name = "paypal_capture_id", unique = true)
    private String paypalCaptureId;

    private Integer status;

    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<VentaDetalle> detalles = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        if (folio == null || folio.isEmpty()) {
            this.folio = UUID.randomUUID().toString().replace("-", "").substring(0,12).toUpperCase();
        }
    }

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getFolio() {
		return folio;
	}

	public void setFolio(String folio) {
		this.folio = folio;
	}

	public LocalDateTime getFecha() {
		return fecha;
	}

	public void setFecha(LocalDateTime fecha) {
		this.fecha = fecha;
	}

	public Double getTotal() {
		return total;
	}

	public void setTotal(Double total) {
		this.total = total;
	}


	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public List<VentaDetalle> getDetalles() {
		return detalles;
	}

	public void setDetalles(List<VentaDetalle> detalles) {
		this.detalles = detalles;
	}

	public String getPaypalOrderId() {
		return paypalOrderId;
	}

	public void setPaypalOrderId(String paypalOrderId) {
		this.paypalOrderId = paypalOrderId;
	}
	public String getPaypalCaptureId() {
	    return paypalCaptureId;
	}

	public void setPaypalCaptureId(String paypalCaptureId) {
	    this.paypalCaptureId = paypalCaptureId;
	}
    
    
}
