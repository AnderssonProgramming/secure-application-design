package com.anderssonprogramming.secureapp.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class TokenService {

    private static final long DEFAULT_TTL_HOURS = 8;

    private final Map<String, SessionToken> sessions = new ConcurrentHashMap<>();
    private final Duration tokenTtl;

    public TokenService(@Value("${app.auth.token-ttl-hours:" + DEFAULT_TTL_HOURS + "}") long tokenTtlHours) {
        this.tokenTtl = Duration.ofHours(tokenTtlHours);
    }

    public String issueToken(TokenPrincipal principal) {
        purgeExpired();
        String token = UUID.randomUUID().toString();
        Instant expiresAt = Instant.now().plus(tokenTtl);
        sessions.put(token, new SessionToken(principal, expiresAt));
        return token;
    }

    public Optional<TokenPrincipal> validate(String token) {
        SessionToken session = sessions.get(token);
        if (session == null) {
            return Optional.empty();
        }
        if (session.expiresAt().isBefore(Instant.now())) {
            sessions.remove(token);
            return Optional.empty();
        }
        return Optional.of(session.principal());
    }

    private void purgeExpired() {
        Instant now = Instant.now();
        sessions.entrySet().removeIf(entry -> entry.getValue().expiresAt().isBefore(now));
    }

    private record SessionToken(TokenPrincipal principal, Instant expiresAt) {
    }
}
