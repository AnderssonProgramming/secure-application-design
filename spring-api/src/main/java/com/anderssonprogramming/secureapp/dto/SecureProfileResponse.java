package com.anderssonprogramming.secureapp.dto;

import java.time.Instant;

public record SecureProfileResponse(
        long userId,
        String email,
        String role,
        Instant createdAt
) {
}
