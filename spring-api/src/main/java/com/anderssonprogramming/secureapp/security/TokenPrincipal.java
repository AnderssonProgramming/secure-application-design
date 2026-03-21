package com.anderssonprogramming.secureapp.security;

public record TokenPrincipal(long userId, String email, String role) {
}
