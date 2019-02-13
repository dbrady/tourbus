spec = Gem::Specification.new do |s|
  s.name = 'tourbus'
  s.version = '0.9.01'
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
  s.add_dependency('optimist')
  s.add_dependency('faker')
  s.add_dependency('hpricot')
  s.add_dependency('webrat', '>= 0.7.0')
  s.add_dependency('pry')
  s.add_dependency('activesupport')
  s.add_dependency('minitest')

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
end
