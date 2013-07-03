Feature: Finding translations by key part
  In order to find translations
  As a user
  I want to be able to type in a part of a translation key
  And Get all translations paginated having this key

  Scenario: Partfinder should include right results
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n?offset=partfinder&partfinder=something'
    Then I should see the translation having key 'nl.prefix.partfinder.suffix'
    And I should not see the translation having key 'nl.prefix.partfinder disabled.suffix'
    And I should see the translation having key 'en.prefix.partfinder.suffix'

  Scenario: Partfinder should include right results when untranslated is set
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
   When I visit '/couchbase_i18n?offset=partfinder&partfinder=something&untranslated=1'
   Then I should not see the translation having key 'nl.prefix.partfinder.suffix'
   And I should not see the translation having key 'nl.prefix.partfinder disabled.suffix'
   And I should see the translation having key 'en.prefix.partfinder.suffix'
