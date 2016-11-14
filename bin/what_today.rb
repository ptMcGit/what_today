#!/usr/bin/env ruby

require 'pry'
require_relative '../lib/what_today/criteria.rb'
require_relative '../lib/what_today/git_wrapper.rb'
require_relative '../lib/what_today/shell_wrapper.rb'
require_relative '../lib/what_today/command_wrapper.rb'
require_relative '../lib/what_today/file_finder.rb'

def debug
  binding.pry
  exit
end

criteria = WhatToday::Criteria.new
git_repos = WhatToday::FileFinder.new(criteria.to_h)

git_shell = WhatToday::CommandWrapper.shell_aliases_for WhatToday::GitWrapper

ignore_directory = lambda { |repo| criteria.ignore_repo? repo }
contains_git_dir = lambda { |repo| not Dir.glob(repo + '/.*').map { |d| File.basename d }.include? '.git' }
is_an_up_to_date_git_repo = lambda { |repo| criteria.ignore_up_to_date && ( git_shell.exec("cd #{repo} && git status -s") == '' ) }

git_repos.add_skip_path_method ignore_directory
git_repos.add_skip_path_method contains_git_dir
git_repos.add_skip_path_method is_an_up_to_date_git_repo

git_repos.files.each do |r|
  system( "clear" )

  git_shell.working_dir = r

  git_shell.git_status
  print "\nVisit repo at #{r} (y/n)? "

  response = gets.chomp
  next unless ["y","Y"].include?(response)
  puts "Starting #{git_shell.preferred_shell} session... You will need to exit before continuing to next repo."
  sleep 1
  WhatToday::ShellWrapper.new_shell(working_dir: r)

end
