require "avo_upgrade/version"
require "avo_upgrade/railtie"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module AvoUpgrade
  # Your code goes here...
end

loader.eager_load
