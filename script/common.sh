#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Upgrade ruby build plugins
cd ~/.rbenv/plugins/ruby-build && git pull && cd -
rbenv install -s $(< .ruby-version)

gem install bundler
bundle install
