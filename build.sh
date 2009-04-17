#!/bin/sh
sudo gem uninstall tourbus 
gem build tourbus.gemspec
sudo gem install $(ls tourbus*.gem|tail -n 1)
