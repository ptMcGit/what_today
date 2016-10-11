require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'

require_relative '../criteria.rb'
require 'pry'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class FileFinderClassTests < MiniTest::Test

  include Find

  class FindMock < FileFinder

    attr_accessor   :ignore_repos, :track_repos, :stub_prune_path
    attr_reader     :stub_files

    def initialize *args
      @stub_files = [
        "/dir",
        "/dir/subdir1",
        "/dir/subdir1/.git",
        "/dir/subdir2",
        "/dir/subdir2/.git",
        "/dir/subdir3",
        "/dir/subdir3/.git",
        "/dir/subdir4"
      ]
      @stub_prune_path = nil

      super *args
    end

    def find_files &block
      catch(:prune) do |p|
        binding.pry
      end

      @stub_files.each &block

    end

#    def prune
#      binding.pry
#      @stub_files.delete_if { |p| p[%r{ #{@stub_prune_path} }] }
#    end

  end

#  def setup
#    @ff = FindMock.new
#  end

  def create_find_mock config=nil
    FindMock.new( criteria: config )
  end

  def test_finds_mock_repos
    ff = create_find_mock
    assert_equal ["/dir/subdir1","/dir/subdir2","/dir/subdir3"], ff.repos
    refute ff.repos.include? "/dir/subdir4"
  end

  def test_ignores_specified_repos
    ff = create_find_mock( {ignore_repos: ["/dir/subdir1"]} )
    assert_equal ["/dir/subdir2", "/dir/subdir3"], ff.repos
  end

  def test_tracks_specified_repos
    ff = create_find_mock( {track_repos: ["/dir/subdir1"]} )
    assert_equal ["/dir/subdir1"], ff.repos
  end

  def test_ignores_takes_precedences
    ff = create_find_mock( {
                             track_repos:   ["/dir/subdir1"],
                             ignore_repos:  ["/dir/subdir2"]
                           } )
    assert_equal ["/dir/subdir1", "/dir/subdir3"], ff.repos
  end

#  focus
  def test_can_prune_paths
    ff = create_find_mock( {prune_paths: ["/dir/subdir2"]} )
    assert_equal ["/dir/subdir1", "/dir/subdir3"], ff.repos
  end



end
