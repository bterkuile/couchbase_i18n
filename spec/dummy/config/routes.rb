Rails.application.routes.draw do

  #devise_for :users

  #devise_for :users #, :controllers => {:sessions => 'cmtool/sessions', :passwords => 'cmtool/passwords'}
  mount CouchbaseI18n::Engine => "/couchbase_i18n", as: 'couchbase_i18n'
  #mount Cmtool::Engine => '/cmtool', as: 'cmtool'
end
