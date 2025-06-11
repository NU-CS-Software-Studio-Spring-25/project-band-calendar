# Cucumber BDD Testing for Band Events Calendar

This project now includes comprehensive functional testing using Cucumber for Behavior-Driven Development (BDD).

## Overview

The Cucumber tests cover two main features of the band events application:

### 1. Event Submission Feature

Tests the functionality for users to submit band events for approval.

**Happy Path:**

- User successfully submits a new event
- Event is created with "pending" status awaiting admin approval

**Sad Paths:**

- User tries to submit event with duplicate name and date (validation error)
- User tries to submit event without required fields (validation error)

### 2. Event Approval Feature

Tests the administrative functionality for approving/disapproving submitted events.

**Happy Paths:**

- Admin successfully approves a pending event
- Admin successfully disapproves (unapproves) an approved event

**Sad Paths:**

- Regular user cannot access approval controls
- Unauthenticated user cannot access approval controls

## Running the Tests

### Prerequisites

Ensure you have all dependencies installed:

```bash
bundle install
```

### Run All Cucumber Tests

```bash
bundle exec cucumber
```

### Run Specific Feature

```bash
bundle exec cucumber features/event_submission.feature
bundle exec cucumber features/event_approval.feature
```

### Run Specific Scenario

```bash
bundle exec cucumber features/event_submission.feature:18  # Run scenario starting at line 18
```

### Run with Tags

```bash
bundle exec cucumber --tags @happy_path    # Run only happy path scenarios
bundle exec cucumber --tags @sad_path      # Run only sad path scenarios
```

## Test Setup

### Database Configuration

- Tests use database transactions for isolation
- Each scenario starts with a clean database state
- Test data is created using FactoryBot factories

### Authentication Testing

- Admin and regular user authentication is tested
- Session management and authorization checks are verified

### Form Interaction

- Real form interactions using Capybara
- Tests validate user input, form submission, and error handling

## File Structure

```
features/
├── event_approval.feature           # Event approval scenarios
├── event_submission.feature         # Event submission scenarios
├── step_definitions/
│   ├── event_approval_steps.rb      # Steps for approval functionality
│   └── event_submission_steps.rb    # Steps for submission functionality
└── support/
    └── env.rb                       # Cucumber environment configuration
```

## Key Testing Scenarios

### Event Submission

1. **Valid Submission**: User submits event with all required fields
2. **Duplicate Prevention**: System prevents duplicate events on same date
3. **Validation**: System validates required fields before submission

### Event Approval

1. **Admin Approval**: Admin can approve pending events
2. **Admin Disapproval**: Admin can unapprove approved events
3. **Authorization**: Non-admin users cannot access approval functions
4. **Visibility**: Approved events are public, pending events are not

## Development Notes

### Factories Used

- `:user` - Creates regular users
- `:user, :admin` - Creates admin users
- `:venue` - Creates event venues
- `:band` - Creates bands
- `:event` - Creates events (default: pending)
- `:event, :approved` - Creates approved events

### Key Validations Tested

- Event name and date presence
- Event name uniqueness per date
- Venue selection requirement
- User authentication for form access
- Admin authorization for approval actions

## Continuous Integration

These tests can be run in CI/CD pipelines to ensure application functionality remains intact across deployments.

Example CI command:

```bash
bundle exec cucumber --format junit --out cucumber_results.xml
```
