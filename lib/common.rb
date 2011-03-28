# common.rb - Common settings, requires and helpers
unless defined? TOURBUS_LIB_PATH
  TOURBUS_LIB_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
  $:<< TOURBUS_LIB_PATH unless $:.include? TOURBUS_LIB_PATH
end

require 'rubygems'

gem 'webrat', ">= 0.7.0"
gem 'mechanize', ">= 1.0.0"
gem 'trollop', ">= 1.10.0"
gem 'faker', '>= 0.3.1'

#! Working around obscure problem introduced with rubygems 1.6 -- whk 20110317
# http://stackoverflow.com/questions/5176782/uninitialized-constant-activesupportdependenciesmutex-nameerror
require 'thread'

# TODO: I'd like to remove dependency on Rails. Need to see what all
# we're using (like classify) and remove each dependency individually.
begin
  require 'activesupport'
rescue Exception
  require 'active_support/all'
end

unless Array.new.respond_to?(:random)
  class Array
    def random
      self[Kernel.rand(length)]
    end
  end
end

require 'monitor'
require 'faker'
require 'tour_bus'
require 'guide'
require 'tourist'

# Our common base class for exceptions
class TourBusException < Exception; end

# The common base class for all exceptions raised by Webrat.
class WebratError < StandardError ; end


def require_all_files_in_folder(folder, extension = "*.rb")
  for file in Dir[File.join('.', folder, "**/#{extension}")]
    require file
  end
end

