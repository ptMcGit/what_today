require_relative './test_helper.rb'

class FileFinderClassTests < MiniTest::Test

  TEST_DIR_PREFIX = File.dirname(Dir.pwd + "/" + $0) + "/test_dir_tree/dir"
  EXPECTED_DIR_ITEMS = Find.find( TEST_DIR_PREFIX ).map do |f|
    f.sub( /#{File.dirname(TEST_DIR_PREFIX)}/,"")
  end.to_a

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

  def create_ff config={}
    f = FileFinder.new( criteria: {start_directory: TEST_DIR_PREFIX}.merge(config) )
    f.remove_test_dir_prefix!
    f
  end

  def test_dir_contents_are_as_expected
    assert_equal EXPECTED_DIR_ITEMS, [
                   "/dir",
                   "/dir/subdir1",
                   "/dir/subdir1/.git",
                   "/dir/subdir2",
                   "/dir/subdir2/.git",
                   "/dir/subdir3",
                   "/dir/subdir3/.git",
                   "/dir/subdir4"
                 ]
  end

  def test_finds_mock_repos
    ff = create_find_mock
    assert_equal ["/dir/subdir1","/dir/subdir2","/dir/subdir3"], ff.repos
    refute ff.repos.include? "/dir/subdir4"
  end

  def test_ignores_specified_repos
    ff = create_find_mock( {ignore_repos: [TEST_DIR_PREFIX + "/subdir1"]} )
    assert_equal ["/dir/subdir2", "/dir/subdir3"], ff.repos
  end

  def test_tracks_specified_repos
    ff = create_find_mock( {track_repos: [TEST_DIR_PREFIX + "/subdir1"]} )
    assert_equal ["/dir/subdir1"], ff.repos
  end

  def test_ignores_takes_precedences
    ff = create_find_mock( {
                             track_repos:   [TEST_DIR_PREFIX + "/subdir1"],
                             ignore_repos:  [TEST_DIR_PREFIX + "/subdir2"]
                           } )
    assert_equal ["/dir/subdir1", "/dir/subdir3"], ff.repos
  end

  def test_can_prune_paths
    ff = create_find_mock( {prune_paths: [TEST_DIR_PREFIX + "/subdir2"]} )
    assert_equal ["/dir/subdir1", "/dir/subdir3"], ff.repos
  end

end
