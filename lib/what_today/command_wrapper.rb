module WhatToday

  class CommandWrapper < ShellWrapper

    def initialize *args
      super *args
      @aliases = {}
    end

    def self.exec_aliases_for module_arg
      self.new.tap do |s|
        s.include_module_as_exec_aliases module_arg
      end
    end

    def self.shell_aliases_for module_arg
      self.new.tap do |s|
        s.include_module_as_shell_aliases module_arg
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

    def include_module_as_exec_aliases module_arg
      if ( defined?(module_arg) && module_arg.is_a?(Module) )
        module_arg.singleton_methods.each do |meth|
          exec_alias(meth.to_s, module_arg.send(meth))
        end
      else
        raise StandardError.new("cannot include module that has not been required")
      end
    end

    def include_module_as_shell_aliases module_arg
      if ( defined?(module_arg) && module_arg.is_a?(Module) )
        module_arg.singleton_methods.each do |meth|
          shell_alias(meth.to_s, module_arg.send(meth))
        end
      else
        raise StandardError.new("cannot include module that has not been required")
      end
    end


  end
end
