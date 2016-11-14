require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'
require 'find'
require 'pry'

require_relative '../criteria.rb'
require_relative '../file_finder.rb'
require_relative '../shell_wrapper.rb'
require_relative '../command_wrapper.rb'
require_relative '../git_wrapper.rb'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

# setup test directory if not setup

TEST_DIR_PREFIX = (File.dirname(__FILE__) + "/test_dir_tree/dir")
EXPECTED_DIR_ITEMS = Find.find( TEST_DIR_PREFIX )

def test_directories
  stem = File.dirname(TEST_DIR_PREFIX)
  [
    "/dir",
    "/dir/subdir1",
    "/dir/subdir1/.git",
    "/dir/subdir2",
    "/dir/subdir3",
    "/dir/subdir3/.git",
    "/dir/subdir4"
  ].map { |i| stem + i }
end

test_directories.each do |path|
  unless File.exist? path
    begin
      Dir.mkdir path
    rescue => e
      puts e
      puts "Unable to create #{path}, which is needed for tests."
      exit 1
    end
  end
end
