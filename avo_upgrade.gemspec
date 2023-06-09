require_relative "lib/avo_upgrade/version"

Gem::Specification.new do |spec|
  spec.name        = "avo_upgrade"
  spec.version     = AvoUpgrade::VERSION
  spec.authors     = ["Adrian Marin"]
  spec.email       = ["adrian@adrianthedev.com"]
  spec.homepage    = "https://avohq.io"
  spec.summary     = "The friendly upgrade helper for Avo."
  spec.description = "The friendly upgrade helper for Avo."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = ": Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/avo-hq/avo_upgrade"
  spec.metadata["changelog_uri"] = "https://github.com/avo-hq/avo_upgrade"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "zeitwerk"
end
