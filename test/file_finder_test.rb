require_relative './test_helper.rb'

class FileFinderClassTests < MiniTest::Test

  def test_finds_all_test_paths_with_no_pruning
    ff = FileFinder.new(start_directory: TEST_DIR_PREFIX)
    assert_equal ff.files.to_a, EXPECTED_DIR_ITEMS.to_a
  end

  def test_prunes_specified_dirs
    ff = FileFinder.new(start_directory: TEST_DIR_PREFIX, prune_paths: ["/dir/subdir2", "/dir/subdir4"])
    assert_equal ff.files.to_a, EXPECTED_DIR_ITEMS.to_a - ["/dir/subdir2", "/dir/subdir4"]
  end

  def test_can_add_skip_path_condition
    ff = FileFinder.new(start_directory: TEST_DIR_PREFIX)
    ff.add_skip_path_method %{{ |path| File.basename(path) != \".git\" }}
    assert_equal ff.files.to_a, EXPECTED_DIR_ITEMS.to_a.reject { |path| File.basename(path) != ".git" }
  end

  def test_can_remove_skip_path_condition
    ff = FileFinder.new(start_directory: TEST_DIR_PREFIX)
    m = "{ true }"
    ff.add_skip_path_method m
    assert_equal ff.files.to_a, []
    ff.remove_skip_path_method "{ true }"
    assert_equal ff.files.to_a, EXPECTED_DIR_ITEMS.to_a
  end

end
