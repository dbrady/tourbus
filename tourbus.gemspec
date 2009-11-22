spec = Gem::Specification.new do |s|
  s.name = 'tourbus'
  s.version = '0.1.2'
  s.date = '2009-11-22'
  s.summary = 'TourBus web stress-testing tool'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/tourbus/"
  s.description = "TourBus, a web stress-testing tool that combines complex 'tour' definitions with scalable concurrent testing"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "Tourbus - Web Stress Testing in Ruby"]
  s.executables = ["tourbus", "tourwatch"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE", "examples/contact_app/README.rdoc"]
  s.authors = ["David Brady", "James Britt", "JT Zemp", "Tim Harper"]
  s.add_dependency('mechanize', '>= 0.8.5')
  s.add_dependency('trollop')
  s.add_dependency('faker')
  s.add_dependency('hpricot')
  s.add_dependency('webrat')


  # ruby -rpp -e "pp (Dir['{README,{examples,lib,protocol,spec}/**/*.{rdoc,json,rb,txt,xml,yml}}'] + Dir['bin/*']).map.sort"
  s.files = ["bin/tourbus",
             "bin/tourwatch",
             "examples/contact_app/README.rdoc",
             "examples/contact_app/contact_app.rb",
             "examples/contact_app/tours/simple.rb",
             "examples/contact_app/tours/tourbus.yml",
             "lib/common.rb",
             "lib/runner.rb",
             "lib/tour.rb",
             "lib/tour_bus.rb",
             "lib/tour_watch.rb"]
end

