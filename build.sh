#!/bin/sh
sudo gem uninstall tourbus dbrady-tourbus
gem build tourbus.gemspec
sudo gem install $(ls tourbus*.gem|tail -n 1)
