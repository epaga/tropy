#!/bin/sh
set -eu

cd "$(dirname "$0")"
bundle exec fastlane ios release_beta
