module CouchbaseI18n
  class ApplicationController < ::ApplicationController
    before_filter :authorize_user
    layout :couchbase_i18n_layout

    private

    def couchbase_i18n_layout
      defined?(Cmtool) ? 'cmtool/application' : 'couchbase_i18n/application'
      # Does not integrate well with cmtool layout at the moment (2012-12-17)
      'couchbase_i18n/application'
    end

    def authorize_user
      if respond_to?(:authorize_couchbase_i18n)
        authorize_couchbase_i18n
      elsif defined?(Cmtool)
        authorize_cmtool
      elsif respond_to?(:current_user) && current_user.respond_to?(:is_admin) && !current_user.is_admin.present?
        redirect_to '/', :alert => I18n.t('couchbase_i18n.general.not_authorized')
      end
    end
  end
end
