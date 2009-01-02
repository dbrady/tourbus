require 'rubygems'
gem 'mechanize', ">= 0.7.6"
gem "hpricot", ">= 0.6"
$: << File.join(File.dirname(__FILE__), 'lib')

require 'hpricot'
require 'mechanize'

WWW::Mechanize.html_parser = Hpricot

require 'web_sickle'
require "assertions"
require "hash_proxy"
require "helpers/asp_net"
require "helpers/table_reader"

Hpricot.buffer_size = 524288
