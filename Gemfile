source "https://rubygems.org"

gem "fastlane"
gem "jazzy"
gem "xcode-install"
gem "cocoapods", "~> 1.7.beta"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
