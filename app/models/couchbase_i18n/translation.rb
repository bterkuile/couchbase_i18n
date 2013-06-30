require 'couchbase/model'
module CouchbaseI18n
  class Translation < Couchbase::Model
    #per_page_method :limit_value

    attribute :translation_key
    attribute :translation_value
    attribute :translated, default: true
    #design_document 'couchbase_i18n/translation'

    #validates_uniqueness_of :translation_key

    #after_save :reload_i18n

    view :all_documents #, :key => :key
    view :by_translation_key #, :key => :key

    view :with_translation_key_array
    view :by_translation_key_part
    view :untranslated_view
    view :untranslated_by_translation_key_part
    view :by_translation_value
    view :untranslated_by_translation_value

    def self.all(options = {})
      paginate options do |opts|
        all_documents(opts)
      end
    end

    def self.count(options = {})
      all_documents(options).count
    end

    def self.get_translation_keys_by_level(level = 0, options = {})
      view = with_translation_key_array(options.merge(reduce: true, include_docs: false, group_level: level.succ))
      # data = data.select{|h| h["key"].size > level } # Only select ones that have a deeper nesting
      #data.map{|h| h['key'][level].try(:to_sym)}.compact
      view.entries.map{|r| r.key.last.try(:to_sym)}
    end

    # Shorthand for selecting all stored with a given offset
    def self.with_offset(offset, options = {})
      options[:startkey] = "#{offset}."
      options[:endkey] = "#{offset}.ZZZZZZZZZ"
      paginate options do |opts|
        by_translation_key(opts)
      end
    end

    def self.find_by_translation_key(key)
      by_translation_key(key: key, limit: 1).entries.first
    end

    def self.paginate(options={}, &block)
      if ([:page, :per_page] & options.keys).any? # Pagination active
        page = [options.delete(:page).to_i, 1].max
        per_page = options.delete(:per_page).to_i # Can be string
        per_page = 30 unless per_page > 0 # Nill will be 0
        total_count = block.call(options.merge(reduce: true, include_docs: false)).count
        result = block.call(options.merge(skip: (page - 1)*per_page, limit: per_page, reduce: false, include_docs: true))
      else
        page = 1
        per_page = 0
        total_count = 0
        result = block.call(options.merge(reduce: false))
      end

      Records.new(result, page: page, per_page: per_page, total_count: total_count)
    end


    # Find all records having the term part in their key
    #   nl.action.one
    #   en.action.two
    #   en.activemodel.plural.models.user
    # and using
    #   find_all_by_part('action')
    # will return the first two since they have action as key part
    def self.find_all_by_translation_key_part(part, options = {})
      options[:key] = part
      paginate options do |opts|
        by_translation_key_part(opts)
      end
    end

    # Find all untranslated records having the term part in their key
    #   nl.action.one
    #   en.action.two
    #   en.activemodel.plural.models.user
    # and using
    #   find_all_by_part('action')
    # will return the first two since they have action as key part
    def self.find_all_untranslated_by_translation_key_part(part, options = {})
      options[:key] = part
      paginate options do |opts|
        untranslated_by_translation_key_part(opts)
      end
    end

    # Find all untranslated records having the term part as value
    #   nl.action.one: 'Value', translated: true
    #   en.action.two: 'Value', translated: false
    #   en.activemodel.plural.models.user: 'Other Value', translated: false
    # and using
    #   find_all_untranslated_by_value('Value')
    # will return en.action.two
    def self.find_all_untranslated_by_translation_value(part, options = {})
      options[:key] = part
      paginate options do |opts|
        untranslated_by_translation_value(opts)
      end
    end

    def self.find_all_by_translation_value(part, options = {})
      options[:key] = part
      paginate options do |opts|
        by_translation_value(opts)
      end
    end


    def self.untranslated(options = {})
      paginate options do |opts|
        untranslated_view(opts)
      end
    end

    def self.untranslated_with_offset(offset, options = {})
      options[:startkey] = "#{offset}."
      options[:endkey] = "#{offset}.ZZZZZZZZZ"
      paginate options do |opts|
        untranslated_view(opts)
      end
    end

    # Expire I18n when record is update
    def reload_i18n
      Rails.cache.write("couchbase_i18n-#{key}", value)
      #I18n.reload!
      #I18n.cache_store.clear if I18n.respond_to?(:cache_store) && I18n.cache_store.respond_to?(:clear)
    end

    def self.deeper_translation_keys_for_offset( offset )
      return get_translation_keys_by_level(0).map{|dl| {:name => dl, :offset => dl}} unless offset.present?
      levels = offset.split('.')
      get_translation_keys_by_level(levels.size, :startkey => levels, :endkey => levels + [{}]).
        map{|dl| {:name => dl, :offset => [offset, dl].join('.')}}
    end

    def self.higher_translation_keys_for_offset( offset )
      return [] unless offset.present?
      higher_translation_keys = []
      levels = offset.split('.')
      return [] unless levels.size > 1
      # Add higher levels. Do not add the last level, since it is the current one => 0..-2
      levels[0..-2].each_with_index do |level_name, i|
        higher_translation_keys<< {
          :name => level_name,
          :offset => levels[0..i].join('.')
        }
      end
      higher_translation_keys
    end

    def destroy
      delete
    end
  end
end
