require_relative './test_helper.rb'

class FileFinderClassTests < MiniTest::Test

  TEST_DIR_PREFIX = File.dirname(Dir.pwd + "/" + $0) + "/test_dir_tree/dir"
  EXPECTED_DIR_ITEMS = Find.find( TEST_DIR_PREFIX )#.map do |f|
#    f.sub( /#{File.dirname(TEST_DIR_PREFIX)}/,"")
#  end.to_a

#   include Find

  class FindMock < FileFinder

    GIT_DIR_NAME=".git_stub"
    attr_accessor   :ignore_repos, :track_repos, :stub_prune_path
    attr_reader     :stub_files

    def remove_test_dir_prefix!
      @repos.map! { |f| f.sub( /#{File.dirname(TEST_DIR_PREFIX)}/,"" ) }
    end
  end



  def create_find_mock config={}
    f = FindMock.new(
      criteria: {start_directory: TEST_DIR_PREFIX}.merge(config)
    )
    f.remove_test_dir_prefix!
    f
  end

#  def create_ff config={}
#    f = FileFinder.new( criteria: {start_directory: TEST_DIR_PREFIX}.merge(config) )
#    f.remove_test_dir_prefix!
#    f
  #  end


  def test_dir_contents_are_as_expected
    assert_equal EXPECTED_DIR_ITEMS, [
                   "/dir",
                   "/dir/subdir1",
                   "/dir/subdir1/.git",
                   "/dir/subdir2",
                   "/dir/subdir3",
                   "/dir/subdir3/.git",
                   "/dir/subdir4"
                 ]
  end

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
