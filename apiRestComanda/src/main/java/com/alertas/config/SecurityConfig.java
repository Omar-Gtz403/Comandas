package com.alertas.config;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .csrf().disable() // necesario para APIs REST
            .authorizeRequests()
                .antMatchers("/api/**", "/auth/**", "/ventas/**").permitAll() // rutas públicas
                .anyRequest().authenticated()
            .and()
            .formLogin(); // o .httpBasic() si es solo API
    }
}
