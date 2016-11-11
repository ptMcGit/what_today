class ShellWrapper

  attr_accessor     :working_dir, :preferred_shell

  def initialize
    @working_dir = '.'
    @preferred_shell       = ENV['SHELL']
    @aliases   = {}
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

  def shell_alias alias_name, command
    @aliases[alias_name.to_sym] = [:shell_command, command]
  end

  def exec_alias alias_name, command
    @aliases[alias_name.to_sym] = [:exec_command, command]
  end

  def process_alias array, *args
    self.send(
      array[0],
      %{#{array[1]} "#{args.join(" ")}"}
    )
  end

  def method_missing (method, *args, &block)
    m = @aliases[method]
   if m
     process_alias(m, *args)
   else
     raise NoMethodError
   end
 end

  def new_shell
    exec_command "exec #{@preferred_shell} -l"
  end

  def include_module_as_exec_aliases module_arg
    if ( defined?(module_arg) && module_arg.is_a?(Module) )
      module_arg::public_instance_methods.each do |meth|
        exec_alias(meth.to_s, module_arg.send(meth))
      end
    else
      raise StandardError.new("cannot include module that has not been required")
    end
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
