#!/usr/bin/env ruby

require 'pry'
require './file_finder.rb'
require './criteria.rb'
require './git_wrapper.rb'
require './helpers.rb'
require './shell_wrapper_parent.rb'
require './shell_wrapper.rb'

require './test_files/test_repos.rb'

include GitWrapper
include Helpers

def debug
  binding.pry
  exit
end

begin
  search_critera = Criteria.for
rescue Criteria::FileNotFoundError => e
  puts "File not found. Using defaults..."
  sleep 1
  search_criteria = Criteria.new
end

#finder = FileFinder.new(search_criteria.prepare)
#repos = process_directories(finder.results)
binding.pry

shell = ShellWrapper.new

repos.each do |r|
  system( "clear" )

  shell.working_dir = r

  next if
    search_criteria.ignore_updated_repos &&
    shell.exec(git_status_ok?).empty?


  shell.shell git_status

  print "\nVisit repo at #{r} (y/n)? "

  response = gets.chomp
  next unless ["y","Y"].include?(response)

  shell.new_shell

end
