require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'

require_relative '../criteria.rb'
require_relative '../wildcard_matcher.rb'
require 'pry'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class CriteriaClassTests < MiniTest::Test
  def assert_for_criteria criteria_object
    assert_equal 4, 4
  end

  def provides_default_config? c
    assert_nil c.instance_variable_get("@config_file")
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    binding.pry
    assert_equal c.instance_variable_get("@prune_paths"),
                 [
                   ENV["HOME"] + "/.Trash",
                   ENV["HOME"] + "/.local"
                 ]
    binding.pry
    assert_equal c.instance_variable_get("@ignored_repos").count,   0
    assert_equal c.instance_variable_get("@tracked_repos").count,   0
  end

  def test_provide_config_for_non_existent_file
    c = Criteria.new(config_file: "./nonexistent_file")
    assert_equal File.exist?( "./nonexistent_file" ), false
    assert provides_default_config?( c ), true
  end

  focus

  def test_process_yaml_test_config_file
    c = Criteria.new(config_file: "./test/test_config.yml")
    assert_equal c.instance_variable_get("@config_file"), "./test/test_config.yml"
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    assert_equal c.instance_variable_get("@ignored_repos").count, 0
    assert_equal c.instance_variable_get("@tracked_repos").count, 2
    assert_equal c.instance_variable_get("@ignore_mode"), false
  end

end





# class AppTests < MiniTest::Test
#   def valid_criteria criteria
# #    return false unless criteria.instance_variables.length == 3
# #    criteria.ignore         # can be nil
# #    criteria.not_ignore     # can be nil
# #    binding.pry
# #    return false unless criteria.start_of_search
# #    true
#   end

#   def create_matcher pattern
#     WildcardMatcher.new(wildcard_patterns: [pattern])
#   end

#   def match?(string, pattern)
#     WildcardMatcher.match?(string, pattern)
#   end

#   def escape_pattern(pattern)
#     o = WildcardMatcher.new(wildcard_patterns: [pattern])
#     o.match_on_pattern("")
#     o.instance_variable_get("@wildcard_lookup")[pattern]
#   end

#   def test_will_return_valid_criteria
# #    c = Criteria.for()
# #    assert valid_criteria(c)
#   end

#   def test_escape_string_literal
#     assert_equal( escape_pattern('pattern'), 'pattern' )
#   end

#   def test_escape_absolute_file_name
#     assert_equal( escape_pattern('/directory'), '\/directory' )
#   end

#   def test_escape_glob
#     assert_equal( escape_pattern('directory*'), 'directory.*')
#   end

#   def test_escape_wildcard
#     assert_eqaul( escape_pattern('file?'), 'file.{1}$')
#     binding.pry
#   end

# end
