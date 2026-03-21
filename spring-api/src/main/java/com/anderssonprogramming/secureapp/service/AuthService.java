package com.anderssonprogramming.secureapp.service;

import com.anderssonprogramming.secureapp.dto.AuthRequest;
import com.anderssonprogramming.secureapp.dto.AuthResponse;
import com.anderssonprogramming.secureapp.model.UserAccount;
import com.anderssonprogramming.secureapp.repository.UserAccountRepository;
import com.anderssonprogramming.secureapp.security.TokenPrincipal;
import com.anderssonprogramming.secureapp.security.TokenService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private static final String DEFAULT_ROLE = "USER";

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public AuthService(UserAccountRepository userAccountRepository,
                       PasswordEncoder passwordEncoder,
                       TokenService tokenService) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    public AuthResponse register(AuthRequest request) {
        if (userAccountRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists");
        }

        String hash = passwordEncoder.encode(request.password());
        UserAccount user = userAccountRepository.save(new UserAccount(request.email(), hash, DEFAULT_ROLE));
        String token = tokenService.issueToken(new TokenPrincipal(user.getId(), user.getEmail(), user.getRole()));

        return new AuthResponse(user.getId(), user.getEmail(), token, "Bearer");
    }

    public AuthResponse login(AuthRequest request) {
        UserAccount user = userAccountRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        String token = tokenService.issueToken(new TokenPrincipal(user.getId(), user.getEmail(), user.getRole()));
        return new AuthResponse(user.getId(), user.getEmail(), token, "Bearer");
    }
}
