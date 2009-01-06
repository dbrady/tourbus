spec = Gem::Specification.new do |s|
  s.name = 'tourbus'
  s.version = '0.0.2'
  s.date = '2009-01-05'
  s.summary = 'TourBus web stress-testing tool'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/tourbus"
  s.description = "TourBus web stress-testing tool"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.txt", "--title", "Tourbus - Web Stress Testing in Ruby"]
  s.executables = ["tourbus", "tourwatch"]
  s.extra_rdoc_files = ["README.txt", "MIT-LICENSE"]
  s.authors = ["David Brady"]
  s.add_dependency('mechanize', '>= 0.8.5')
  s.add_dependency('trollop')
  s.add_dependency('faker')
  s.add_dependency('hpricot')


  # ruby -rpp -e "pp (Dir['{README,{examples,lib,protocol,spec}/**/*.{json,rb,txt,xml}}'] + Dir['bin/*']).map.sort"
  s.files = ["bin/tourbus",
             "bin/tourwatch",
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
