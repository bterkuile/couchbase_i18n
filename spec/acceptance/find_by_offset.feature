Feature: Finding translations by offset
  In order to find translations
  As a user
  I want to be able to type in an offset
  And Get all translations paginated having the typed in value as key offset

  Scenario: Showing all translations when no offset is given
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n'
    Then I should see the translation having key 'nl.prefix.partfinder.suffix'
    And I should see the translation having key 'nl.prefix.partfinder disabled.suffix'
    And I should see the translation having key 'en.prefix.partfinder.suffix'

  Scenario: Show all untranslated when no offset is given
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n?untranslated=1'
    And I should not see the translation having key 'nl.prefix.partfinder.suffix'
    And I should see the translation having key 'nl.prefix.partfinder disabled.suffix'
    And I should see the translation having key 'en.prefix.partfinder.suffix'

  Scenario: Show the proper ones when an offset is given
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n?offset=nl'
    And I should see the translation having key 'prefix.partfinder.suffix'
    And I should see the translation having key 'prefix.partfinder disabled.suffix'
    And I should not see the translation having key 'Other Value'

  Scenario:  Show the proper ones when an offset is given and untranslated=1
    Given a signed in user
    And there are the following translations:
      | Key                                  | Value       | Translated? |
      | nl.prefix.partfinder.suffix          | Value       | yes         |
      | nl.prefix.partfinder disabled.suffix | Value       | no          |
      | en.prefix.partfinder.suffix          | Other Value | no          |
    When I visit '/couchbase_i18n?offset=nl&untranslated=1'
    And I should not see the translation having key 'prefix.partfinder.suffix'
    And I should see the translation having key 'prefix.partfinder disabled.suffix'
    And I should not see the translation having key 'Other Value'
