package com.example.demo.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class PayPalHttpService {

	@Value("${paypal.client-id}")
	private String clientId;

	@Value("${paypal.secret}")
	private String secret;

	@Value("${paypal.mode}")
	private String mode;

	private final RestTemplate restTemplate = new RestTemplate();

	public Map<String, Object> obtenerOrden(String orderId) {

		String baseUrl = mode.equalsIgnoreCase("live") ? "https://api-m.paypal.com"
				: "https://api-m.sandbox.paypal.com";

		String url = baseUrl + "/v2/checkout/orders/" + orderId;

		HttpHeaders headers = new HttpHeaders();
		headers.setBasicAuth(clientId, secret);
		headers.setAccept(List.of(MediaType.APPLICATION_JSON));

		HttpEntity<Void> entity = new HttpEntity<>(headers);

		ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

		return response.getBody();
	}

	public void reembolsarPago(String captureId, Double total) {

		String baseUrl = mode.equalsIgnoreCase("live") ? "https://api-m.paypal.com"
				: "https://api-m.sandbox.paypal.com";

		String url = baseUrl + "/v2/payments/captures/" + captureId + "/refund";

		HttpHeaders headers = new HttpHeaders();
		headers.setBasicAuth(clientId, secret);
		headers.setContentType(MediaType.APPLICATION_JSON);

		String body = "{" + "\"amount\":{" + "\"value\":\"" + String.format("%.2f", total) + "\","
				+ "\"currency_code\":\"MXN\"" + "}" + "}";

		HttpEntity<String> entity = new HttpEntity<>(body, headers);

		restTemplate.postForEntity(url, entity, Map.class);
	}

}
