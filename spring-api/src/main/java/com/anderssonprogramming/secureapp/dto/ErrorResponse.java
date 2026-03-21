package com.anderssonprogramming.secureapp.dto;

import java.time.Instant;

public record ErrorResponse(
        String message,
        Instant timestamp
) {
}
