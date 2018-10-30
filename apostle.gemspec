require File.expand_path('lib/apostle/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Mal Curtis']
  gem.email         = ['mal@sitepoint.com']
  gem.description   = ': Send emails via Apostle'
  gem.summary       = ': Send emails via Apostle'
  gem.homepage      = 'http://apostle.io'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'apostle'
  gem.require_paths = ['lib']
  gem.version       = Apostle::VERSION

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'webmock'
end
