require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'

require_relative '../criteria.rb'
require 'pry'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class CriteriaClassTests < MiniTest::Test
  def assert_for_criteria criteria_object
    assert_equal 4, 4
  end

  def provides_default_config? c
    assert_nil c.instance_variable_get("@config_file")
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    assert_equal c.instance_variable_get("@prune_paths"),
                 [
                   ENV["HOME"] + "/.Trash",
                   ENV["HOME"] + "/.local"
                 ]
    assert_equal c.instance_variable_get("@ignored_repos").count,   0
    assert_equal c.instance_variable_get("@tracked_repos").count,   0
  end

  def test_provide_config_for_non_existent_file
    c = Criteria.new(config_file: "./nonexistent_file")
    assert_equal File.exist?( "./nonexistent_file" ), false
    assert provides_default_config?( c ), true
  end

  def test_process_yaml_test_config_file
    c = Criteria.new(config_file: "./test/test_config.yml")
    assert_equal c.instance_variable_get("@config_file"), "./test/test_config.yml"
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    assert_equal c.instance_variable_get("@ignored_repos").count, 0
    assert_equal c.instance_variable_get("@tracked_repos").count, 2
  end

end
