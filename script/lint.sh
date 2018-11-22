#!/bin/bash

BASE="$(cd "$(dirname "$0")"; pwd)"
source "$BASE/common.sh"

bundle exec ensure_latest_carthage
bundle exec fastlane lint