# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "couchbase_i18n"
  s.authors = ["Benjamin ter Kuile"]
  s.email = %q{bterkuile@gmail.com}
  s.homepage = %q{http://github.com/bterkuile/couchbase_i18n}
  s.rubyforge_project = "couchbase_i18n"
  s.summary = "couch_i18n is an in database storage for I18n translations, tested for rails, with online management views"
  s.description = "couch_i18n is an in database storage for I18n translations, tested for rails, with online management views"
  s.files = Dir["lib/**/*"] + Dir["app/**/*"] + Dir["config/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.add_dependency 'activemodel' #, '>= 3'
  s.add_dependency 'couchbase'
  s.version = "0.4.0"
end
