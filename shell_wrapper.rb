module ShellWrapper

  # start a new shell in the given directory (is a child)
  def new_shell start_directory="."
    system("cd #{start_directory} && exec #{ENV['SHELL']} -l ")
  end

  # run the command in the destination folder
  def exec_method(command_string, destination=".")
    system( "cd #{destination} && #{command_string}" )
  end

  def shell_command(command_string, destination=".")
    %x[ cd #{destination} && #{command_string} ]
  end


end
