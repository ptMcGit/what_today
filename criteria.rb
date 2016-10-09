require 'yaml'
require './file_finder.rb'

class Criteria
  attr_reader :start_of_search, :ignore, :not_ignore, :ignore_updated_repos

  class FileNotFoundError < StandardError
  end

  def initialize opts={config_file: "none"}
    @config_file            = opts[:config_file]
    set_configs

#    opts = default_config_file if opts.empty?
#    @start_of_search        = opts[:start_of_search] ||= get_home_dir
#    @ignore                 = opts[:ignore]
#    @ignore_updated_repos   = opts[:ignore_updated_repos]

   end

  def valid_data? data

    loop do

      break unless data.class == Hash

      # if data has keys that the mock doesn't, break

      mock = parse_mock_config_file

      data.keys.each do |key|
        break unless mock[key]
        break unless data[key].class == mock[key].class
      end


      return true
    end

    return false
  end

  def valid_file?
    loop do
      break unless File.exist?(@config_file)
      return true
    end
    @config_file = nil
  end

  def process_config_file
    loop do

      break unless valid_file?
      data = parse_config_file
      break unless valid_data? data
      return data
    end
    # TODO: there was a problem with your config_file
    return {}
  end

  def set_configs
    # use defaults
    configs = parse_mock_config_file

    # combine with those defaults
    configs.merge! process_config_file

    assign_configs( configs )
  end

  def assign_configs config_data
    @start_of_search    = config_data["start_of_search"]    ||= home_dir
    @prune_paths        = config_data["prune_paths"]        ||= []
    @ignored_repos      = config_data["ignored_repos"]      ||= []
    @tracked_repos      = config_data["tracked_repos"]      ||= []
    @ignore_mode        = @ignored_repos.count > 0
  end

  def yaml_parse lines
    YAML.load lines
  end

  def parse_config_file
#    File.read(@config_file) do |line| end
    File.open(@config_file) do |line|
      yaml_parse line
    end
  end

  def parse_mock_config_file
    StringIO.open( mock_config_file ) do |line|
      yaml_parse line
    end
  end

#  def process_config_file(config_file)
#    parse_config_file( load_config_file(config_file) )
#  end

  def mock_config_file
    %{
      start_of_search:  #{home_dir}
      prune_paths:
        - #{home_dir}/.Trash
        - #{home_dir}/.local
      ignore_repos:
      track_repos:
    }
  end

  def prepare
    {
      start_directory:      @start_of_search,
      include_file_types:   ["d"],
      ignore_paths:         @ignore,
      names:                ['.git']
    }
  end

  def home_dir
    # home directory, or current_directory
    return @home_dir if @home_dir

    @home_dir = (ENV['HOME'] ||= ( Dir.chdir && Dir.pwd ))
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
      ignore:                  ["*/.Trash","*/.local"],
      ignore_updated_repos:    true
    }
  end

  #def self.config_file
  #  return @config_file if File.exist?(@config_file || "")
  #  "#{home_dir}/application.yml"
  #end

  def self.home_dir
    ENV['HOME'] ||= (Dir.chdir && Dir.pwd)
  end

end
