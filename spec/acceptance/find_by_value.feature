Feature: Finding translations by value
  In order to find translations
  As a user
  I want to be able to type in a value
  And Get all translations paginated having this value

  Scenario: Value finder should include right results
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n?offset=Value&valuefinder=something'
    Then I should see the translation having key 'nl.prefix.partfinder.suffix'
    And I should see the translation having key 'nl.prefix.partfinder disabled.suffix'
    And I should not see the translation having key 'en.prefix.partfinder.suffix'

  Scenario: Value finder should include right results when untranslated is set
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
   When I visit '/couchbase_i18n?offset=Value&valuefinder=something&untranslated=1'
   Then I should not see the translation having key 'nl.prefix.partfinder.suffix'
   And I should see the translation having key 'nl.prefix.partfinder disabled.suffix'
   And I should not see the translation having key 'en.prefix.partfinder.suffix'
