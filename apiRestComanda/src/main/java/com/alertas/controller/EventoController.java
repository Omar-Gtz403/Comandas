package com.alertas.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alertas.entity.Evento;
import com.alertas.service.EventoService;

@RestController
@RequestMapping("/api/eventos")
@CrossOrigin("*")
public class EventoController {

    @Autowired
    private EventoService eventoService;

    @GetMapping
    public List<Evento> listarEventos() {
        return eventoService.obtenerTodos();
    }

    @GetMapping("/{id}")
    public Optional<Evento> obtenerEvento(@PathVariable Integer id) {
        return eventoService.obtenerPorId(id);
    }

    @PostMapping
    public Evento crearEvento(@RequestBody Evento evento) {
        return eventoService.guardar(evento);
    }

    @PutMapping("/{id}")
    public Evento actualizarEvento(@PathVariable Integer id, @RequestBody Evento evento) {
        evento.setId(id);
        return eventoService.guardar(evento);
    }

    @DeleteMapping("/{id}")
    public void eliminarEvento(@PathVariable Integer id) {
        eventoService.eliminar(id);
    }
}
