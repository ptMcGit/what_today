require_relative './helper.rb'
require 'tempfile'

class CriteriaClassTests < MiniTest::Test

  def config_file_template
    %{
start_of_search: #{ENV['HOME']}
ignore_up_to_date: true
prune_paths:
  - /repo_2
  - /repo_2
ignored_repos:
tracked_repos:
}
  end

  def provides_default_config? c
    assert_nil c.instance_variable_get("@config_file")
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    assert_equal c.instance_variable_get("@ignore_up_to_date"), true
    assert_equal c.instance_variable_get("@prune_paths"),
                 [
                   ENV["HOME"] + "/.Trash",
                   ENV["HOME"] + "/.local"
                 ]
    assert_equal c.instance_variable_get("@ignored_repos").count,   0
    assert_equal c.instance_variable_get("@tracked_repos").count,   0
  end

  def test_provide_config_for_non_existent_file
    c = WhatToday::Criteria.new(config_file: "./nonexistent_file")
    assert_equal File.exist?( "./nonexistent_file" ), false
    assert provides_default_config?( c ), true
  end

  def test_process_yaml_test_config_file
    require 'tempfile'
    cf = Tempfile.new(File.basename($0))
    cf.write(config_file_template)
    c = WhatToday::Criteria.new(config_file: cf)
    assert_equal c.instance_variable_get("@config_file"), cf
    assert_equal c.instance_variable_get("@ignore_up_to_date"), true
    assert_equal c.instance_variable_get("@start_of_search"), ENV["HOME"]
    assert_equal c.instance_variable_get("@ignored_repos").count, 0
    assert_equal c.instance_variable_get("@tracked_repos").count, 0
  end

  def test_does_not_ignore_file_that_is_tracked
    c = WhatToday::Criteria.new
    tr = ["/dir"]
    c.instance_variable_set("@tracked_repos", tr)
    assert_equal c.ignore_repo?(tr[0]), false
  end

  def test_ignores_file_that_is_ignored
    c = WhatToday::Criteria.new
    tr = ["/dir"]
    c.instance_variable_set("@ignored_repos", tr)
    assert_equal c.ignore_repo?(tr[0]), true
  end

  def test_tracks_repo_when_ignored_and_tracked
    c = WhatToday::Criteria.new
    tr = ["/dir"]
    c.instance_variable_set("@tracked_repos", tr)
    c.instance_variable_set("@ignored_repos", tr)
    assert_equal c.ignore_repo?(tr[0]), false
  end

  def test_tracks_repos_not_ignored_or_tracked
    c = WhatToday::Criteria.new
    tr = ["/dir"]
    assert_equal c.ignore_repo?(tr[0]), false
  end

  def test_when_tracking_ignore_untracked
    c = WhatToday::Criteria.new
    tr = ["/dir"]
    c.instance_variable_set("@tracked_repos", tr)
    assert_equal c.ignore_repo?("/my_dir"), true
  end

end
