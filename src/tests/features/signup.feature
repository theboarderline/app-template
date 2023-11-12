
#@auth
#Feature: Authentication
#
#  Scenario: Signup, validate token, register marina
#    When I send "GET" request to the "api" service at "/auth/check"
#    Then the response code should be 204
#
#    When I send a signup request to the "api" service at "/auth/signup" with random data
#    Then the response code should be 201
#
#    When I send "GET" request to the "api" service at "/auth/check"
#    Then the response code should be 200
#    And the response should contain a "user"
#
#    When I send a login request to the "api" service at "/auth/login" with the current user
#    Then the response code should be 200
#    And the response should contain a "token"
#    And the token should be saved for future requests
#
#    When I send "GET" request to the "api" service at "/auth/check"
#    Then the response code should be 200
#    And the response should contain a "user"
