module CouchbaseI18n
  class Store

    def available_locales
      CouchbaseI18n::Translation.get_translation_keys_by_level(0)
    end

    # Now the store features
    def []=(key, value, options = {})
      key = key.to_s.gsub('/', '.')
      existing = CouchbaseI18n::Translation.find_by_translation_key(key) rescue nil
      translation = existing || CouchbaseI18n::Translation.new(:translation_key => key)
      translation.translation_value = value
      translation.save
    end

    # alias for read
    def [](key, options = {})
      key = key.to_s.gsub('/', '.')
      Rails.cache.fetch("couchbase_i18n-#{key}") do
        translation = CouchbaseI18n::Translation.find_by_translation_key(key.to_s)
        translation ||= CouchbaseI18n::Translation.create(:translation_key => key, :translation_value => options[:default].presence || key.to_s.split('.').last, :translated => false)
        translation.translation_value
      end
    end

    def translation_keys
      CouchbaseI18n::Translation.all.map(&:translation_key)
    end
  end
end
