require 'spec_helper'

describe CouchbaseI18n::Translation do
  before :each do
    @t1 = CouchbaseI18n::Translation.create(translation_key: 'nl.prefix.partfinder.suffix', translation_value: 'Value', translated: true)
    @t2 = CouchbaseI18n::Translation.create(translation_key: 'nl.prefix.partfinder disabled.suffix', translation_value: 'Value', translated: false)
    @t3 = CouchbaseI18n::Translation.create(translation_key: 'en.prefix.partfinder.suffix', translation_value: 'Value', translated: false)
  end

  describe 'all' do
    it 'paginates the result' do
      CouchbaseI18n::Translation.all(page: 1, per_page: 2).to_a.should == [@t3, @t2]
      CouchbaseI18n::Translation.all(page: 2, per_page: 2).should == [@t1]
    end

  end

  describe "find by part" do
    it "should find all by part independent of locale" do
      CouchbaseI18n::Translation.find_all_by_translation_key_part('partfinder').sort_by(&:translation_key).should == [@t3, @t1]
    end
    it "should find all by part independent of locale that are untranslated if required" do
      CouchbaseI18n::Translation.find_all_untranslated_by_translation_key_part('partfinder').should == [@t3]
    end
  end

  describe :untranslated do
    it "should return untranslated translations" do
      CouchbaseI18n::Translation.untranslated.sort_by(&:translation_key).should == [@t3, @t2]
    end

    it "should return untranslated from an offset" do
      CouchbaseI18n::Translation.untranslated_with_offset('en').should == [@t3]
    end
  end

  describe :deeper_translation_keys_for_offset do
    it "should return the locales with proper translation_key name when offset is an empty string" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset('').map{|h| h[:name] }.sort.should == [:en, :nl]
    end
    it "should return the locales with proper translation_key name when offset is nil" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset(nil).map{|h| h[:name]}.sort.should == [:en, :nl]
    end
    it "should return the locales with proper offset when offset is an empty string" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset('').map{|h| h[:offset] }.sort.should == [:en, :nl]
    end
    it "should return the locales with proper offset when offset is nil" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset(nil).map{|h| h[:offset]}.sort.should == [:en, :nl]
    end

    it "should return the deeper offset translation_key names when offset is given" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset('nl.prefix').map{|h| h[:name]}.sort.should == [:partfinder, :'partfinder disabled']
    end
    it "should return the deeper offset translation_keys with proper offset when offset is given" do
      CouchbaseI18n::Translation.deeper_translation_keys_for_offset('nl.prefix').map{|h| h[:offset]}.sort.should == ["nl.prefix.partfinder", "nl.prefix.partfinder disabled"]
    end
  end

  describe :higher_translation_keys_for_offset do
    it "should return an empty array when offset is an empty string" do
      CouchbaseI18n::Translation.higher_translation_keys_for_offset('').should == []
    end
    it "should return an empty array when offset is nil" do
      CouchbaseI18n::Translation.higher_translation_keys_for_offset(nil).should == []
    end

    it "should return an empty array when the offset is one level deep" do
      CouchbaseI18n::Translation.higher_translation_keys_for_offset('nl').should == []
    end

    it "should return the proper names when three levels deep is given" do
      CouchbaseI18n::Translation.higher_translation_keys_for_offset('a.b.c').map{|h| h[:name] }.should == %w[a b]
    end

    it "should return the proper offsets when three levels deep is given" do
      CouchbaseI18n::Translation.higher_translation_keys_for_offset('a.b.c').map{|h| h[:offset] }.should == %w[a a.b]
    end

  end

  describe 'it should be able to return only exact the current level' do
    before :each do
      @t4 = CouchbaseI18n::Translation.create(translation_key: 'en.other.suffix', translation_value: 'Value')
      @t5 = CouchbaseI18n::Translation.create(translation_key: 'en.other.suffix.deeper_suffix', translation_value: 'Value')
    end

    it "should be implemented" do
      pending
    end
  end

  describe 'find by translation_value' do
    before :each do
      @t4 = CouchbaseI18n::Translation.create(translation_key: 'en.other.suffix', translation_value: 'Other Value')
      @t5 = CouchbaseI18n::Translation.create(translation_key: 'en.other.suffix.deeper_suffix', translation_value: 'Other Value')
    end
    it "should return translations with the same translation_value Value" do
      CouchbaseI18n::Translation.find_all_by_translation_value('Value').sort_by(&:translation_key).should == [@t3, @t2, @t1]
    end
    it "should return translations with the same translation_value Other Value" do
      CouchbaseI18n::Translation.find_all_by_translation_value('Other Value').sort_by(&:translation_key).should == [@t4, @t5]
    end
  end
end
