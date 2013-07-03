Feature: Import yml files
  In order to add and update translations
  As a user
  I can upload a YAML file containing the translations

  Scenario: Add and upload translations
    Given a signed in user
    When I click on the import button
    And supply a yml translations file
    And I click the import button
    Then I should see new translations from the file
    And I should see existing translations updated
    And Other translations should still be there

