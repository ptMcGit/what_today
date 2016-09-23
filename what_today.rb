#!/usr/bin/env ruby

require 'pry'
require './file_finder.rb'
require './criteria.rb'
require './git_wrapper.rb'
require './helpers.rb'
require './shell_wrapper.rb'
require './test_files/test_repos.rb'

include GitWrapper
include ShellWrapper
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

repos.each do |dest|
  system( "clear" )
  next if
    shell_command(git_status_ok?, dest).empty? &&
    search_criteria.ignore_updated_repos

  exec_method(git_status, dest)

  print "\nVisit repo at #{dest} (y/n)? "

  response = gets.chomp
  next unless ["y","Y"].include?(response)

  new_shell dest

end
