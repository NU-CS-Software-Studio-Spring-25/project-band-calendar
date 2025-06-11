Feature: Event Approval
  As an admin user
  I want to approve or disapprove submitted events
  So that only appropriate events are published to the community

  Background:
    Given the following venues exist:
      | name           | street_address    | city        |
      | The Music Hall | 123 Main St      | San Francisco |
    And the following bands exist:
      | name           |
      | The Rockers    |
    And I am registered as an admin with email "admin@example.com" and password "password123"
    And a regular user exists with email "user@example.com"

  @happy_path
  Scenario: Admin successfully approves a pending event
    Given a pending event exists:
      | name            | date       | venue          | submitted_by       |
      | Rock Night 2024 | 2024-09-20 | The Music Hall | user@example.com   |
    And I am signed in as an admin
    When I visit the event details page for "Rock Night 2024"
    And I click the "Approve" button
    Then I should see "Event has been approved"
    And the event should be marked as approved
    And the event should be visible to all users

  @happy_path
  Scenario: Admin successfully disapproves an approved event
    Given an approved event exists:
      | name            | date       | venue          | submitted_by       |
      | Rock Night 2024 | 2024-09-20 | The Music Hall | user@example.com   |
    And I am signed in as an admin
    When I visit the event details page for "Rock Night 2024"
    And I click the "Unapprove" button
    Then I should see "Event has been unapproved"
    And the event should be marked as not approved
    And the event should not be visible to regular users

  @sad_path
  Scenario: Regular user cannot access approval controls
    Given a pending event exists:
      | name            | date       | venue          | submitted_by       |
      | Rock Night 2024 | 2024-09-20 | The Music Hall | user@example.com   |
    And I am signed in as a regular user with email "user@example.com"
    When I visit the event details page for "Rock Night 2024"
    Then I should not see approval buttons
    And I should not be able to access approval endpoints directly

  @sad_path
  Scenario: Unauthenticated user cannot access approval controls
    Given a pending event exists:
      | name            | date       | venue          | submitted_by       |
      | Rock Night 2024 | 2024-09-20 | The Music Hall | user@example.com   |
    When I visit the event details page for "Rock Night 2024" without being signed in
    Then I should not see approval buttons
    And I should be redirected to sign in if I try to access approval endpoints 