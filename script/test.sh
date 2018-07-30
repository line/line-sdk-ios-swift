export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Upgrade ruby build plugins
cd ~/.rbenv/plugins/ruby-build && git pull && cd -

rbenv install -s 2.5.0

gem install bundler
bundle install

bundle exec fastlane tests