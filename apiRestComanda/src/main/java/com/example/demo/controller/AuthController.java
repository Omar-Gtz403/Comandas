package com.example.demo.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.entity.Usuario;
import com.example.demo.service.UsuarioService;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioService usuarioService;

    public AuthController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/register")
    public ResponseEntity<Usuario> register(@RequestBody Usuario usuario) {
        return ResponseEntity.ok(usuarioService.registrar(usuario));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String nombreUsuario = body.get("nombreUsuario");
        String password = body.get("password");

        Optional<Usuario> usuario = usuarioService.login(nombreUsuario, password);
        if (usuario.isPresent()) {
            if (usuario.get().getPermiso() == 1) {
                return ResponseEntity.ok(usuario.get());
            } else {
                return ResponseEntity.status(403).body("No tienes permisos administrativos");
            }
        }
        return ResponseEntity.status(401).body("Usuario o contraseña incorrectos");
    }
}

