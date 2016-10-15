require 'find'

class FileFinder

  GIT_DIR_NAME=".git"

  attr_reader :repos
  attr_reader :start_directory

  include Find

  def initialize opts={criteria: nil}
    if opts[:criteria]
      opts = opts[:criteria].to_h
    end

    @start_directory    = opts[:start_directory]    ||= "."
    @ignore_repos       = opts[:ignore_repos]       ||= []
    @track_repos        = opts[:track_repos]        ||= []
    @prune_paths        = opts[:prune_paths]        ||= []

    @repos              = []
    query!
  end

  def ignore_repos= arg
    raise TypeError if (arg.class != Array)
  end

  def track_repos= arg
    raise TypeError if (arg.class != Array)
  end

  def find_files &block
    find(@start_directory).each &block
  end

  def query!
    @repos = []
    find_files do |path|
      prune if should_prune_path? path
      next if File.basename(path) != GIT_DIR_NAME
      if not @ignore_repos.empty?
        @repos.push(File.dirname( path )) unless @ignore_repos.include?(File.dirname( path ))
      elsif not @track_repos.empty?
        @repos.push(File.dirname( path )) if @track_repos.include?(File.dirname( path ))
      else
        @repos.push(File.dirname( path ))
      end
    end
  end

  def should_prune_path? path
    @prune_paths.include? path
  end

  def match_on_pattern(string, pattern)
    p = pattern.gsub('.','\.').gsub('/','\/').gsub('*','.*')
    string[/#{p}/]
  end
end
