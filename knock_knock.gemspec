lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knock_knock/version'

Gem::Specification.new do |spec|
  spec.name          = 'knock_knock'
  spec.version       = KnockKnock::VERSION
  spec.authors       = ['Kacper Madej']
  spec.email         = ['kacperoza@gmail.com']

  spec.summary       = 'IP rate limiter'
  spec.description   = 'IP rate limiter'
  spec.homepage      = 'https://github.com/madejejej/knock_knock'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-configurable', '~> 0.7.0'
  # Ruby lacks an official priority queue implementation.
  # Not sure if this is the best choice, but there aren't any alternatives on GH.
  spec.add_dependency 'PriorityQueue', '~> 0.1.2'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'timecop', '0.9.1'
end
