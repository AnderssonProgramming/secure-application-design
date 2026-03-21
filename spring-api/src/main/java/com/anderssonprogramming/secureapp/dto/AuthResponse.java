package com.anderssonprogramming.secureapp.dto;

public record AuthResponse(
        long userId,
        String email,
        String token,
        String tokenType
) {
}
