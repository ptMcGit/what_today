module WhatToday
  class ShellWrapper

    attr_accessor     :working_dir, :preferred_shell

    def initialize opts={}
      @working_dir      = opts[:working_dir] ||= '.'
      @preferred_shell  = ENV['SHELL']
    end

    def exec command
      exec_command command
    end

    def shell command
      shell_command command
    end

    def working_dir= dir
      if File.exist?(dir)
        @working_dir = dir
      else
        raise StandardError.new("argument to directory assignemnt is invalid")
      end
    end

    def preferred_shell= shell
      if is_valid_shell? shell
        @preferred_shell = shell
      else
        raise StandardError.new("argument to shell assignment is invalid")
      end
    end

    def self.new_shell opts={}
      self.new(opts).tap do |s|
        s.open_prompt
        s
      end
    end

    def open_prompt
      system( "#{cd} && exec #{preferred_shell} -l")
    end

    private

    def exec_command command
      %x[ #{cd} && #{@preferred_shell} -c '#{command}' ]
    end

    def shell_command command
      system( "#{cd} && #{@preferred_shell} -c '#{command}'" )
    end

    def cd
      "cd #{@working_dir}"
    end

    def is_valid_shell? shell
      [
        "/bin/bash",
        "/bin/sh"
      ].include? shell
    end

  end
end
