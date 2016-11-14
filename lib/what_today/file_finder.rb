module WhatToday
  require 'find'

  class FileFinder

    attr_reader :files
    attr_reader :start_directory

    include Find

    def initialize opts={criteria: nil}
      if opts[:criteria]
        opts = opts[:criteria].to_h
      end

      @start_directory    = opts[:start_directory]    ||= "."
      @prune_paths        = opts[:prune_paths]        ||= []
      @files              = find_files

      @skip_path_conditions = {}
    end

    def find_files
      Enumerator.new do |yielder|
        find(@start_directory).each do |path|
          prune if @prune_paths.include? path
          yielder.yield(path) unless skip_path?(path)
        end
      end
    end

    # path is skipped if this evaluates to true
    def add_skip_path_method block_as_string
      @skip_path_conditions[block_as_string] = eval("Proc.new" + block_as_string)
    end

    def remove_skip_path_method block_as_string
      @skip_path_conditions.delete_if { |k,v| k == block_as_string }
    end

    def skip_path? path
      @skip_path_conditions.values.each do |m|
        return true if m.call(path)
      end
      return false
    end

  end
end
