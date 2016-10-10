require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'

require_relative '../criteria.rb'
require 'pry'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class FileFinderClassTests < MiniTest::Test

  include Find

  class FindMock < FileFinder

    attr_accessor :ignore_repos, :track_repos

    def initialize *args
      super *args
    end

    def file_tree
      [
        "/dir",
        "/dir/subdir1",
        "/dir/subdir1/.git",
        "/dir/subdir2",
        "/dir/subdir2/.git",
        "/dir/subdir3"
      ].to_enum
    end

  end

  def setup
    @ff = FindMock.new
  end

  def mock_results object
  end

  def find_repos_current_dir
    Array(
      find(File.dirname( $0 ))
    )
  end

  def test_finds_mock_repos
    assert_equal ["/dir/subdir1","/dir/subdir2"], @ff.repos
  end

  def test_ignores_specified_repos
    @ff.ignore_repos.push("/dir/subdir1")
    @ff.query!
    assert_equal ["/dir/subdir2"], @ff.repos
  end

  def test_tracks_specified_repos
    @ff.track_repos.push("/dir/subdir1")
    @ff.query!
    assert_equal ["/dir/subdir1"], @ff.repos
  end


end
