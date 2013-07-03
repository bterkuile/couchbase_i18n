Feature: Export yml files
  In order to export translations
  As a user
  I can download a YAML file containing the translations

  Scenario: Export translations
    Given a signed in user
    When I click on the export button button
    And select yml as export format
    And I click the export button
    Then I should get and export file having the proper translation structure
