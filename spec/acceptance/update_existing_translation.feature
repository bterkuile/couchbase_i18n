Feature: Updating existing translation
  In order to update a translation
  As a user
  I want to be able to update an existing translation

  Scenario: Updating an existing translation
    Given a signed in user
    And There is an existing translation
    When I visit the existing translation edit path
    And I fill in the value field with 'Updated Value'
    And I click the submit button
    Then I should see 'Translation is successfully updated'
    And I should see 'Updated Value'
