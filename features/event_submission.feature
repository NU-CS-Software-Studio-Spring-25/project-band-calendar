Feature: Event Submission
  As a registered user
  I want to submit band events
  So that they can be reviewed and published for the community

  Background:
    Given the following venues exist:
      | name           | street_address    | city        |
      | The Music Hall | 123 Main St      | San Francisco |
      | Rock Venue     | 456 Rock Ave     | San Francisco |
    And the following bands exist:
      | name           |
      | The Rockers    |
      | Jazz Quartet   |
    And I am registered as a user with email "user@example.com" and password "password123"

  @happy_path
  Scenario: User successfully submits a new event
    Given I am signed in as a regular user
    When I visit the new event page
    And I fill in the event form with:
      | field     | value                |
      | Name      | Summer Rock Concert  |
      | Date      | 2024-08-15           |
      | Venue     | The Music Hall       |
    And I submit the event
    Then I should see "Event was submitted and is awaiting approval"
    And the event should be created with status "pending"
    And the event should be associated with the current user

  @sad_path
  Scenario: User tries to submit event with duplicate name and date
    Given an approved event exists with name "Summer Rock Concert" and date "2024-08-15"
    And I am signed in as a regular user
    When I visit the new event page
    And I fill in the event form with:
      | field     | value                |
      | Name      | Summer Rock Concert  |
      | Date      | 2024-08-15           |
      | Venue     | Rock Venue           |
    And I submit the event
    Then I should see "An event named 'Summer Rock Concert' already exists on August 15, 2024"
    And no new event should be created

  @sad_path
  Scenario: User tries to submit event without required fields
    Given I am signed in as a regular user
    When I visit the new event page
    And I submit the event without filling required fields
    Then I should see validation errors for required fields
    And no new event should be created 