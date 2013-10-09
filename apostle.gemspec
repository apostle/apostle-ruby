# -*- encoding: utf-8 -*-
require File.expand_path('../lib/apostle/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mal Curtis"]
  gem.email         = ["mal@sitepoint.com"]
  gem.description   = %q{: Send emails via Apostle}
  gem.summary       = %q{: Send emails via Apostle}
  gem.homepage      = "http://apostle.io"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "apostle"
  gem.require_paths = ["lib"]
  gem.version       = Apostle::VERSION

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "webmock"
end
