require 'yaml'
require './file_finder.rb'

class Criteria
  attr_reader :start_of_search, :ignore, :not_ignore, :ignore_updated_repos

  class FileNotFoundError < StandardError
  end

  def initialize opts={}
    opts = default_config_file if opts.empty?
    @start_of_search        = opts[:start_of_search] ||= get_home_dir
    @ignore                 = opts[:ignore]
    @ignore_updated_repos   = opts[:ignore_updated_repos]
   end

  def prepare
    {
      start_directory:      @start_of_search,
      include_file_types:   ["d"],
      ignore_paths:         @ignore,
      names:                ['.git']
    }
  end

  def get_home_dir
    ENV['HOME'] ||= (Dir.chdir && Dir.pwd)
  end

  def self.for
    if FileTest.exists? config_file
      self.new(YAML.load_file(config_file))
    else
      raise FileNotFoundError
    end
  end

  def self.for_defaults
    self.new
  end

  def default_config_file
    {
      ignore:                  ["*/.Trash/*","*/.local/*"],
      ignore_updated_repos:    true
    }
  end

 def self.config_file
    "#{home_dir}/application.yml"
 end

  def self.home_dir
    ENV['HOME'] ||= (Dir.chdir && Dir.pwd)
  end

end
