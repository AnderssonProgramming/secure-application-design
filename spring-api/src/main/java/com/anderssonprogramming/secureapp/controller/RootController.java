package com.anderssonprogramming.secureapp.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class RootController {

    @GetMapping("/")
    public Map<String, Object> index() {
        return Map.of(
                "service", "Secure Spring API",
                "status", "UP",
                "timestamp", Instant.now().toString(),
                "publicHealthEndpoint", "/api/public/health"
        );
    }
}
