
@health
Feature: Health Checks

  Scenario Outline: API health check
    When I send "<method>" request to the "<service>" service at "<endpoint>"
    Then the response code should be "<status>"

    Examples:
      | service | method | endpoint | status |
      | api     | GET    | /        | 200    |
#      | api     | GET   | /private | 401    |
