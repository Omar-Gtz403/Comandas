package com.example.demo.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.entity.Usuario;
import com.example.demo.entity.Rol;
import com.example.demo.service.UsuarioService;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final UsuarioService usuarioService;

    public AuthController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/register")
    public ResponseEntity<Usuario> register(@RequestBody Usuario usuario) {
        Usuario nuevo = usuarioService.registrar(usuario);
        return ResponseEntity.ok(nuevo);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        Optional<Usuario> usuario = usuarioService.login(body.get("nombreUsuario"), body.get("password"));

        if (usuario.isPresent()) {
            Usuario u = usuario.get();

            if (u.getRol() == null) {
                return ResponseEntity.status(403).body("El usuario no tiene un rol asignado");
            }

            // 🔹 Evitar enviar la contraseña
            u.setPassword(null);

            // 🔹 Retornar el usuario con su rol y permisos incluidos
            Rol rol = u.getRol();
            rol.getPermisos().size(); // Fuerza la carga de permisos si son LAZY

            return ResponseEntity.ok(u);
        }

        return ResponseEntity.status(401).body("Usuario o contraseña incorrectos");
    }
}
