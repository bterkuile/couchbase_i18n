=begin MOVED TO GHERKIN (turnip)
require 'acceptance/acceptance_helper'

feature 'Translations', %q{
  In order have dynamic translations
  As a user
  I want to be able to manage translations
} do

  background do
    CouchbaseI18n::ApplicationController.any_instance.stub(:authorize_user).and_return true
  end

  scenario 'root path should be translations index' do
    visit '/couchbase_i18n'
    page.should have_content 'No translations found'
  end

  context 'with records' do
    before :each do
      @t1 = CouchbaseI18n::Translation.create(translation_key: 'nl.prefix.partfinder.suffix', translation_value: 'Value', translated: true)
      @t2 = CouchbaseI18n::Translation.create(translation_key: 'nl.prefix.partfinder disabled.suffix', translation_value: 'Value', translated: false)
      @t3 = CouchbaseI18n::Translation.create(translation_key: 'en.prefix.partfinder.suffix', translation_value: 'Other Value', translated: false)
    end

    context :partfinder do
      scenario 'partfinder should include right results' do
        visit '/couchbase_i18n?offset=partfinder&partfinder=something'
        page.should have_content 'nl.prefix.partfinder.suffix'
        page.should_not have_content 'nl.prefix.partfinder disabled.suffix'
        page.should have_content 'en.prefix.partfinder.suffix'
      end

      scenario 'partfinder should include right results when untranslated is set' do
        visit '/couchbase_i18n?offset=partfinder&partfinder=something&untranslated=1'
        page.should_not have_content 'nl.prefix.partfinder.suffix'
        page.should_not have_content 'nl.prefix.partfinder disabled.suffix'
        page.should have_content 'en.prefix.partfinder.suffix'
      end
    end

    context :valuefinder do
      scenario 'value finder should include right results' do
        visit '/couchbase_i18n?offset=Value&valuefinder=something'
        page.should have_content 'nl.prefix.partfinder.suffix'
        page.should have_content 'nl.prefix.partfinder disabled.suffix'
        page.should_not have_content 'en.prefix.partfinder.suffix'
      end

      scenario 'value finder should include right results when untranslated is set' do
        visit '/couchbase_i18n?offset=Value&valuefinder=something&untranslated=1'
        page.should_not have_content 'nl.prefix.partfinder.suffix'
        page.should have_content 'nl.prefix.partfinder disabled.suffix'
        page.should_not have_content 'en.prefix.partfinder.suffix'
      end
    end

    context :offset do
      scenario "should show all when no offset is given" do
        visit '/couchbase_i18n'
        page.should have_content 'nl.prefix.partfinder.suffix'
        page.should have_content 'nl.prefix.partfinder disabled.suffix'
        page.should have_content 'en.prefix.partfinder.suffix'
      end

      scenario "should show all untranslated when no offset is given" do
        visit '/couchbase_i18n?untranslated=1'
        page.should_not have_content 'nl.prefix.partfinder.suffix'
        page.should have_content 'nl.prefix.partfinder disabled.suffix'
        page.should have_content 'en.prefix.partfinder.suffix'
      end

      scenario "should show the proper ones when an offset is given" do
        visit '/couchbase_i18n?offset=nl'
        page.should have_content 'prefix.partfinder.suffix'
        page.should have_content 'prefix.partfinder disabled.suffix'
        page.should_not have_content 'Other Value'
      end

      scenario "should show the proper ones when an offset is given and untranslated=1" do
        visit '/couchbase_i18n?offset=nl&untranslated=1'
        page.should_not have_content 'prefix.partfinder.suffix'
        page.should have_content 'prefix.partfinder disabled.suffix'
        page.should_not have_content 'Other Value'
      end
    end

    scenario "update an existing translation" do
      visit "/couchbase_i18n/translations/#{@t2.id}/edit"
      fill_in 'translation[translation_value]', with: 'Updated Value'
      page.find_button('Update').click
      page.should have_content 'Updated Value'
      page.should have_content 'Translation is successfully updated'
    end
  end

  scenario 'create new translation' do

  end

  context :import do
    scenario "import yml" do
      pending
    end
  end

  context :export do
    scenario "test export" do
      pending
    end
  end

end
=end
