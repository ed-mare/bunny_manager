
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunny_manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'bunny_manager'
  spec.version       = BunnyManager::VERSION
  spec.authors       = ['ed.mare']

  spec.summary       = 'Connnection and channel manager for RabbitMQ Bunny client.'
  spec.description   = 'Provides a connection pool of RabbitMQ channels so it can be used safely with threads.'
  spec.homepage      = 'https://github.com/ed-mare/bunny_manager'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'bunny', '~> 2.8'
  spec.add_dependency 'connection_pool', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'bundler-audit', '~> 0.6'
  spec.add_development_dependency 'bunny-mock', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '>= 0.52'
end
