module WhatToday
  require 'yaml'

  class Criteria
    attr_reader :start_of_search

    class FileNotFoundError < StandardError
    end

    def initialize opts={config_file: "none"}
      @config_file            = opts[:config_file]

      set_configs
    end

    def to_h
      {
        start_directory:  @start_of_search,
        ignore_repos:     @ignored_repos,
        track_repos:      @tracked_repos,
        prune_paths:      @prune_paths
      }
    end

    def ignore_repo? path
      if not @tracked_repos.empty?
        return false if @tracked_repos.include? path
      elsif not @ignored_repos.empty?
        return true if @ignored_repos.include? path
      else
        return false
      end
    end

    protected

    def set_configs
      # use defaults
      configs = parse_mock_config_file

      # combine with those defaults
      configs.merge! process_config_file

      assign_configs( configs )
    end

    def parse_mock_config_file
      StringIO.open( mock_config_file ) do |line|
        yaml_parse line
      end
    end

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

    def home_dir
      # home directory, or current_directory
      return @home_dir if @home_dir

      @home_dir = (ENV['HOME'] ||= ( Dir.chdir && Dir.pwd ))
    end


    def yaml_parse lines
      YAML.load lines
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

    def valid_file?
      loop do
        break unless File.exist?(@config_file)
        return true
      end
      @config_file = nil
    end

    def parse_config_file
      File.open(@config_file) do |line|
        yaml_parse line
      end
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

    def assign_configs config_data
      @start_of_search    = config_data["start_of_search"]    ||= home_dir
      @prune_paths        = config_data["prune_paths"]        ||= []
      @ignored_repos      = config_data["ignored_repos"]      ||= []
      @tracked_repos      = config_data["tracked_repos"]      ||= []
    end

  end
end
