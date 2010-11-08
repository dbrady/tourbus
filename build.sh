#!/bin/sh
gem uninstall tourbus
gem build tourbus.gemspec
gem install $(ls tourbus*.gem|tail -n 1)
