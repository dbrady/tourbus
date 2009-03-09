spec = Gem::Specification.new do |s|
  s.name = 'tourbus'
  s.version = '0.0.7'
  s.date = '2009-01-10'
  s.summary = 'TourBus web stress-testing tool'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/tourbus"
  s.description = "TourBus web stress-testing tool"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.txt", "--title", "Tourbus - Web Stress Testing in Ruby"]
  s.executables = ["tourbus", "tourwatch"]
  s.extra_rdoc_files = ["README.txt", "MIT-LICENSE", "examples/contact_app/README.rdoc"]
  s.authors = ["David Brady"]
  s.add_dependency('mechanize', '>= 0.8.5')
  s.add_dependency('trollop')
  s.add_dependency('faker')
  s.add_dependency('hpricot')


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
             "lib/tour_watch.rb",
             "lib/web-sickle/init.rb",
             "lib/web-sickle/lib/assertions.rb",
             "lib/web-sickle/lib/hash_proxy.rb",
             "lib/web-sickle/lib/helpers/asp_net.rb",
             "lib/web-sickle/lib/helpers/table_reader.rb",
             "lib/web-sickle/lib/make_nokigiri_output_useful.rb",
             "lib/web-sickle/lib/web_sickle.rb",
             "lib/web-sickle/spec/lib/helpers/table_reader_spec.rb",
             "lib/web-sickle/spec/spec_helper.rb",
             "lib/web-sickle/spec/spec_helpers/mechanize_mock_helper.rb",
             "lib/web-sickle/spec/web_sickle_spec.rb"]
end
