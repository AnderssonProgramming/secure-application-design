package com.anderssonprogramming.secureapp.controller;

import com.anderssonprogramming.secureapp.dto.SecureProfileResponse;
import com.anderssonprogramming.secureapp.model.UserAccount;
import com.anderssonprogramming.secureapp.repository.UserAccountRepository;
import com.anderssonprogramming.secureapp.security.TokenPrincipal;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/secure")
public class SecureController {

    private final UserAccountRepository userAccountRepository;

    public SecureController(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    @GetMapping("/me")
    public SecureProfileResponse me(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof TokenPrincipal principal)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }

        UserAccount user = userAccountRepository.findById(principal.userId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized"));

        return new SecureProfileResponse(user.getId(), user.getEmail(), user.getRole(), user.getCreatedAt());
    }
}
