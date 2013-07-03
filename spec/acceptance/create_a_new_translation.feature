Feature: Create a new translation
  In order to create a translation
  As a user
  I want to be able to fill in a form and save a new translation

  Scenario: Creating a new translation
    Given a signed in user
    When I visit the new translation path
    And I fill in the key field with 'en.couchbase_i18n.general.test_message_ending_key'
    And I fill in the value field with 'New translation Value'
    And I click the submit button
    Then I should see 'Translation is successfully created'
    And I should see 'test_message_ending_key'
    And I should see 'New translation Value'
