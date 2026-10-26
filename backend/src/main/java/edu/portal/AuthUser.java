package edu.portal;

public record AuthUser(long id, String email, String role, boolean mustChangePassword) {}
