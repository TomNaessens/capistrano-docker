lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-docker'
  spec.version       = '0.4.0'
  spec.authors       = ["Jacek Jakubik", "Michael Khabarov", "Tom Naessens"]
  spec.email         = ["michaelkhabarov@alphastate.ru"]
  spec.description   = %q{Docker support for Capistrano 3.x}
  spec.summary       = %q{Docker support for Capistrano 3.x}
  spec.homepage      = 'https://github.com/michaelkhabarov/capistrano-docker'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.3'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
