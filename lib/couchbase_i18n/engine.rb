require 'i18n'
module CouchbaseI18n
  class Engine < ::Rails::Engine
    isolate_namespace CouchbaseI18n
    initializer 'couchbase_i18n.cmtool', after: 'cmtool.build_menu' do
      if defined? Cmtool
        require 'cmtool'
        Cmtool::Menu.register do
          append_to :site do
            resource_link CouchbaseI18n::Translation, label: :couchbase_i18n
          end
        end
      end
    end
  end
end
