package com.example.demo.config;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.demo.entity.Venta;
import com.example.demo.repository.VentaRepository;

@Component
public class VentaScheduler {

    @Autowired
    private VentaRepository ventaRepository;

    // Ejecutar todos los días a las 2:00 AM
    @Scheduled(cron = "0 0 2 * * ?")
    public void eliminarVentasNoPagadas() {
        LocalDateTime limite = LocalDateTime.now().minusDays(1);
        List<Venta> pendientes = ventaRepository.findByStatusAndFechaBefore(0, limite);

        if (!pendientes.isEmpty()) {
            ventaRepository.deleteAll(pendientes);
            System.out.println("🗑 Se eliminaron " + pendientes.size() + " ventas en estatus 'Esperando pago'");
        }
    }
}
