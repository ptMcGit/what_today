class ShellWrapper

  attr_accessor     :working_dir

  def initialize
    @working_dir = '.'
    @shell       = ENV['SHELL']
    @aliases   = {}
  end

  def exec command
    exec_command command
  end

  def shell command
    shell_command command
  end

  #def working_dir=
  #end

  def shell_alias alias_name, command
    @aliases[alias_name.to_sym] = [:shell_command, command]
  end

  def exec_alias alias_name, command
    binding.pry
    @aliases[alias_name.to_sym] = [:exec_command, command]
  end

  def process_alias array
    self.send(array[0], array[1])
  end

  def method_missing (method, *args, &block)
    if m = @aliases[method]
      process_alias m
    else
      raise NoMethodError
    end
  end

  def respond_to_missing? method
    binding.pry
  end
  # start a new shell in the given directory (is a child)

  def new_shell
    exec_command "exec #{@shell} -l"
  end

  private

  def exec_command command
    %x[ #{cd} && #{@shell} -c "#{command}" ]
  end

  def shell_command command
    system( "#{cd} && #{@shell} -c \"#{command}\"" )
  end

  def cd
    "cd #{@working_dir}"
  end

end
