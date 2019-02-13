# common.rb - Common settings, requires and helpers
unless defined? TOURBUS_LIB_PATH
  TOURBUS_LIB_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
  $:<< TOURBUS_LIB_PATH unless $:.include? TOURBUS_LIB_PATH
end

require 'rubygems'

#! Working around obscure problem introduced with rubygems 1.6 -- whk 20110317
# http://stackoverflow.com/questions/5176782/uninitialized-constant-activesupportdependenciesmutex-nameerror
require 'thread'
require 'pry'

require 'active_support/all'

unless Array.new.respond_to?(:random)
  class Array
    def random
      self[Kernel.rand(length)]
    end
  end
end

require 'test/unit/testcase'
unless defined?(Test::Unit::AssertionFailedError)
  # paper over the fact that ruby 1.9(?) doesn't have Test::Unit::AssertionFailedError
  class Test::Unit::AssertionFailedError < MiniTest::Assertion
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
