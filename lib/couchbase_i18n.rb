require "couchbase_i18n/engine"
require 'couchbase_i18n/store'
require 'couchbase_i18n/backend'
require 'couchbase_i18n/active_model_errors'

# Ugly fix for the updated json gem changes
module JSON
  class << self
    alias :old_parse :parse
    def parse(json, args = {})
      args[:create_additions] = true
      old_parse(json, args)
    end
  end
end

module CouchbaseI18n
  # This method imports yaml translations to the couchdb version. When run again new ones will
  # be added. Translations already stored in the couchdb database are not overwritten if true or ovveride_existing: true is given
  def self.import_from_yaml(options = {})
    options = {:override_existing => true} if options.is_a?(TrueClass)
    options = {:override_existing => false} if options.is_a?(FalseClass)
    options = {:override_existing => false}.merge!(options)
    raise "I18.backend not a I18n::Backend::Chain" unless I18n.backend.is_a?(I18n::Backend::Chain)
    # 
    yml_backend = I18n.backend.backends.last

    raise "Last backend not a I18n::Backend::Simple" unless yml_backend.is_a?(I18n::Backend::Simple)
    yml_backend.load_translations
    flattened_hash = traverse_flatten_keys(yml_backend.send(:translations))
    available_translations = CouchbaseI18n::Translation.all
    flattened_hash.each do |key, value|
      available_translation = available_translations.find{|t| t.key == key}
      if available_translation && options[:override_existing]
        available_translation.value = value
        available_translation.translated = true
        available_translation.save
      else
        available_translation = CouchbaseI18n::Translation.create :key => key, :value => value
      end
    end
  end

  # Recursive flattening.
  def self.traverse_flatten_keys(obj, store = {}, path = nil)
    case obj
    when Hash
     obj.each{|k, v| traverse_flatten_keys(v, store, [path, k].compact.join('.'))}
    when Array
      # Do not store array for now. There is no good solution yet
      store[path] = obj # Keeyp arrays intact
      # store[path] = obj.to_json
      # obj.each_with_index{|v, i| traverse_flatten_keys(store, v, [path, i].compact.join('.'))}
    else
      store[path] = obj
    end
    return store
  end

  # This will return an indented strucutre of a collection of stores. If no argument is given
  # by default all the translations are indented. So a command:
  #   CouchbaseI18n.indent_keys.to_yaml will return one big yaml string of the translations
  def self.indent_keys(selection = CouchbaseI18n::Translation.all)
    traverse_indent_keys(selection.map{|kv| [kv.key.split('.'), kv.value]})
  end

  # Traversing helper for indent_keys
  def self.traverse_indent_keys(ary, h = {})
    for pair in ary
      if pair.first.size == 1
        h[pair.first.first] = pair.last
      else
        h[pair.first.first] ||= {}
        next unless h[pair.first.first].is_a?(Hash) # In case there is a translation en.a: A, en.a.b: B this is invalid
        traverse_indent_keys([[pair.first[1..-1], pair.last]], h[pair.first.first])
      end
    end
    h
  end

  # Add all translations to the cache to avoid one by one loading and caching
  def self.cache_all
    CouchbaseI18n::Translation.all.each do |t|
      Rails.cache.write("couchbase_i18n-#{t.key}", t.value)
    end
  end
end

# Now extend the I18n backend
I18n.backend = I18n::Backend::Chain.new(CouchbaseI18n::Backend.new(CouchbaseI18n::Store.new), I18n.backend) unless Rails.env == 'test'
I18n.load_path += Dir.glob(File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*'))
