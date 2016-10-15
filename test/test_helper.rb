require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'
require 'find'
require 'pry'

require_relative '../criteria.rb'
require_relative '../file_finder.rb'
require_relative '../shell_wrapper.rb'
require_relative '../git_wrapper.rb'

include GitWrapper

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new
