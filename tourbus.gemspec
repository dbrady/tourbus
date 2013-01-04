spec = Gem::Specification.new do |s|
  s.name = 'tourbus'
  s.version = '2.0.1'
  s.date = '2010-09-23'
  s.summary = 'TourBus web stress-testing tool'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/tourbus/"
  s.description = "TourBus, a web load-testing tool that combines complex 'tour' definitions with scalable, concurrent testing"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "Tourbus - Web Load Testing in Ruby"]
  s.executables = ["tourbus", "tourwatch", "tourproxy"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE", "examples/contact_app/README.rdoc"]
  s.authors = ["David Brady", "James Britt", "JT Zemp", "Tim Harper", "Joe Tanner"]
  s.add_dependency('mechanize', '>= 1.0.0')
  s.add_dependency('trollop')
  s.add_dependency('faker')
  s.add_dependency('hpricot')
  s.add_dependency('webrat', '>= 0.7.0')
  s.add_dependency('activesupport', '>= 3.0.0')


  # ruby -rpp -e "pp (Dir['{README,{examples,lib,protocol,spec}/**/*.{rdoc,json,rb,txt,xml,yml}}'] + Dir['bin/*']).map.sort"
  s.files = [
    "bin/tourbus",
    "bin/tourproxy",
    "bin/tourwatch",
    "examples/contact_app/README.rdoc",
    "examples/contact_app/contact_app.rb",
    "examples/contact_app/tours/simple.rb",
    "examples/contact_app/tours/tourbus.yml",
    "lib/common.rb",
    "lib/file.rb",
    "lib/runner.rb",
    "lib/tour_bus.rb",
    "lib/tour_proxy.rb",
    "lib/tour_rat.rb",
    "lib/tour_watch.rb",
    "lib/tourist.rb",
    "lib/webrat_headers_patch.rb",
    "spec/lib/tourproxy_spec.rb",
    "spec/spec_helper.rb"
  ]
end

