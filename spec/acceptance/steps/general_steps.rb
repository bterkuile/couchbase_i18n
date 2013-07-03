step "a signed in user" do
  CouchbaseI18n::ApplicationController.any_instance.stub(:authorize_user).and_return true
end

step "there are the following translations:" do |table|
  table.hashes.each do |tspec|
    CouchbaseI18n::Translation.create(translation_key: tspec['Key'], translation_value: tspec['Value'], translated: tspec['Translated?'] == 'yes')
  end
end

step "I visit :url" do |url|
  visit url
end

step "I should see :content" do |content|
  page.should have_content content
end

step "I should see the translation having key :key" do |key|
  page.should have_content key
end

step "I should not see the translation having key :key" do |key|
  page.should_not have_content key
end

step "There is an existing translation" do
  @existing_translation = CouchbaseI18n::Translation.create(
    translation_key: 'nl.prefix.some.path',
    translation_value: 'Value',
    translated: true
  )
end

step "I visit the new translation path" do
  visit "/couchbase_i18n/translations/new"
end

step "I visit the existing translation edit path" do
  visit "/couchbase_i18n/translations/#{@existing_translation.id}/edit"
end

step "I fill in the key field with :key" do |key|
  fill_in 'translation[translation_key]', with: key
end

step "I fill in the value field with :value" do |value|
  fill_in 'translation[translation_value]', with: value
end

step "I open the debugger" do
  binding.pry
end

step "I click the submit button" do
  find('[name="commit"][type="submit"]').click
end

step "I click on the import button" do

end
