#!/usr/bin/env ruby

require 'find'
require 'yaml'
require 'pry'

IGNORE_FILE     = '~/ignore.yml'
ignore_file = YAML.load_file(IGNORE_FILE)

DEFAULT_TREE    = ENV['HOME'] ||= (Dir.chdir && Dir.pwd)
START_OF_DAY    = "6am"
GIT_FOLDER      = ".git"

repos_to_check = []

Find.find(DEFAULT_TREE) do |path|
  #repos_to_check.push if
  if path =~ /#{GIT_FOLDER}$/ && FileTest.directory?(path)
    binding.pry
  end
end
