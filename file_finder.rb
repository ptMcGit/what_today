require 'find'
#include File

GIT_DIR_NAME=".git"

class FileFinder

  attr_reader :repos
  attr_reader :start_directory, :include_file_types, :exclude_file_types, :name, :results

  include Find

  def initialize opts={criteria: nil}
    @start_directory    = opts[:start_directory] ||= "."
    @save_patterns
#    @names              = escape_strings( opts[:names] )
#    @include_file_types = opts[:include_file_types]
#    @exclude_file_types = opts[:exclude_file_types]
    @ignore_repos       = opts[:ignore_repos] ||= []
    @track_repos        = opts[:track_repos] ||= []
    #    @ignore_repos       = escape_strings( opts[:ignore_repos] )
    @repos              = []
    query!
  end

  def escape_strings array
    #
    array.map { |i| i.sub(/(.*)/, '\'\1\'') }
  end


  def ignore_repos= arg
    raise TypeError if (arg.class != Array)
  end

  def ignore_repos= arg
    raise TypeError if (arg.class != Array)
  end

  def file_tree
    find(@start_directory)
  end

  def query!
    @repos = []
    file_tree.each do |path|
      next if File.basename(path) != GIT_DIR_NAME
      if not @ignore_repos.empty?
        @repos.push(File.dirname( path )) unless @ignore_repos.include?(File.dirname( path ))
      elsif not @track_repos.empty?
        @repos.push(File.dirname( path )) if @track_repos.include?(File.dirname( path ))
      else
        @repos.push(File.dirname( path ))
      end
#      prune if should_prune_path?(path)
#      puts path if File.basename(path) == GIT_DIR_NAME
    end



      #      File.basename(path) == name

#    @query = prepare_arguments
    #
    #%x[ find #{@start_directory} -type d -print0  ].split("\u0000")
#    @results = %x[ find #{@query} ].split("\u0000")
  end

  def should_prune_path? path

    @ignore_repos.each do |pattern|

      return true if match_on_pattern(path, pattern)
    end
    return false
  end

  def match_on_pattern(string, pattern)
    p = pattern.gsub('.','\.').gsub('/','\/').gsub('*','.*')
    string[/#{p}/]
  end

  def ignore_paths

  end


  def prepare_arguments
    #
    @start_directory + " " +
      prepare_file_args +
      prepare_names +
      prepare_paths
  end

  def prepare_file_args
    includes = []
    excludes = []
    both     = []

    if @include_file_types
      @include_file_types.each do |i|
        includes.push " -type #{i} "
      end
      both.push '\(' + includes.join(" -o ") + '\)'
    end

    if @exclude_file_types
      @exclude_file_types.each do |e|

        excludes.push " ! -type #{e} "
      end
      both.push '\(' + excludes.join(" -o ") + '\)'
    end

    return both.join(" -a " ) if both.any?
    ""
  end

  def prepare_names
    " -name " + @names[0]
  end

  def prepare_paths
    return ' -print0 ' unless @ignore_paths

    ' -a \( ' +

    @ignore_paths.map { |path|
      " -path " + path + " -prune -o "
    }.join +

    ' -print0 \) '

    #' -a \( -path ' + @ignore_paths.join(" -prune -o ") + " -prune -o -print0 " + ' \)'
  end
end
