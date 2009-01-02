# Add your own tasks in files placed in lib/tasks ending in .rake, for
# example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::RDocTask.new do |rd|
  rd.main = "README.txt"
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include("README.txt", "bin/*", "lib/**/*.rb")
end
