package main

import (
	"strings"
)

type Response struct {
	Token   string      `json:"token" binding:"required"`
	Message string      `json:"msg"`
	User    User        `json:"user"`
	Results interface{} `json:"results"`
}

type LoginRequest struct {
	Phone    string `json:"phone"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type User struct {
	ID        int    `json:"id"`
	Email     string `json:"email"`
	Password  string `json:"password"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
}

type SignupRequest struct {
	FirstName       string `json:"first_name" binding:"required"`
	LastName        string `json:"last_name" binding:"required"`
	Email           string `json:"email" binding:"required"`
	Password        string `json:"password" binding:"required"`
	ConfirmPassword string `json:"confirm_password" binding:"required"`
	Phone           string `json:"phone" binding:"required"`
}

func trimString(input string) string {
	return strings.TrimSpace(strings.ReplaceAll(input, "\n", ""))
}
