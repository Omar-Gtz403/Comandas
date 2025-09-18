package com.example.demo;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.apache.catalina.connector.Connector;
@SpringBootApplication
public class DemoApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(DemoApplication.class);
    }
    @Configuration
    public class TomcatConfig {

        @Bean
        public WebServerFactoryCustomizer<TomcatServletWebServerFactory> servletContainer() {
            return factory -> {
                // Conector HTTP que redirige a HTTPS
                Connector connector = new Connector(TomcatServletWebServerFactory.DEFAULT_PROTOCOL);
                connector.setScheme("http");
                connector.setPort(8080);       // HTTP interno
                connector.setSecure(false);
                connector.setRedirectPort(8443); // HTTPS interno
                factory.addAdditionalTomcatConnectors(connector);
            };
        }
    }

}
