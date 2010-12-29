# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/file'))
require 'spec/autorun'
require 'ruby-debug'
# require File.here('../features/factories/fixjour_definitions')
# require File.here('../test/bdrb_test_helper')

# Requires all files in a folder relative to .. (project root).
def require_all_files_in_folder(folder, extension = '*.rb')
  for file in Dir[File.join(File.expand_path(File.dirname(__FILE__)), '..', folder, "**/#{extension}")]
    require file
  end
end

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
require_all_files_in_folder "spec/support"
require_all_files_in_folder "lib"
