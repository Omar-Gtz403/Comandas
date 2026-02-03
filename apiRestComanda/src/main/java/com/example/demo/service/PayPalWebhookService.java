package com.example.demo.service;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class PayPalWebhookService {
    @Value("${paypal.client-id}")
    private String clientId;

    @Value("${paypal.secret}")
    private String secret;

    @Value("${paypal.webhook-id}")
    private String webhookId;

    @Value("${paypal.mode}")
    private String mode;

    private final RestTemplate restTemplate = new RestTemplate();

    public boolean validarFirma(
            Map<String, String> headers,
            Map<String, Object> body
    ) {

        String baseUrl = mode.equalsIgnoreCase("live")
                ? "https://api-m.paypal.com"
                : "https://api-m.sandbox.paypal.com";

        String url = baseUrl + "/v1/notifications/verify-webhook-signature";

        Map<String, Object> payload = Map.of(
                "auth_algo", headers.get("paypal-auth-algo"),
                "cert_url", headers.get("paypal-cert-url"),
                "transmission_id", headers.get("paypal-transmission-id"),
                "transmission_sig", headers.get("paypal-transmission-sig"),
                "transmission_time", headers.get("paypal-transmission-time"),
                "webhook_id", webhookId,
                "webhook_event", body
        );

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setBasicAuth(clientId, secret);
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity =
                new HttpEntity<>(payload, httpHeaders);

        ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);

        return "SUCCESS".equals(
                response.getBody().get("verification_status")
        );
    }
}

