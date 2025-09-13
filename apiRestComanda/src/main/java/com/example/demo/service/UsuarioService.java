package com.example.demo.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Usuario;
import com.example.demo.repository.UsuarioRepository;

import java.util.Optional;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UsuarioService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    public Usuario registrar(Usuario usuario) {
        usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
        return usuarioRepository.save(usuario);
    }

    public Optional<Usuario> login(String nombreUsuario, String password) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByNombreUsuario(nombreUsuario);
        if (usuarioOpt.isPresent() && passwordEncoder.matches(password, usuarioOpt.get().getPassword())) {
            return usuarioOpt;
        }
        return Optional.empty();
    }
}
