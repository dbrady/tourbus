# common.rb - Common settings, requires and helpers
unless defined? TOURBUS_LIB_PATH
  TOURBUS_LIB_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
  $:<< TOURBUS_LIB_PATH unless $:.include? TOURBUS_LIB_PATH
end

require 'rubygems'

gem 'mechanize', ">= 0.8.5"
gem 'trollop', ">= 1.10.0"
gem 'faker', '>= 0.3.1'

# TODO: I'd like to remove dependency on Rails. Need to see what all
# we're using (like classify) and remove each dependency individually.
require 'activesupport'

require 'monitor'
require 'faker'
require 'web-sickle/init'
require 'tour_bus'
require 'runner'
require 'tour'

class TourBusException < Exception; end

def require_all_files_in_folder(folder, extension = "*.rb")
  for file in Dir[File.join('.', folder, "**/#{extension}")]
    require file
  end
end

