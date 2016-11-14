require_relative './helper.rb'

class CommandWrapperTests < MiniTest::Test

  TEST_MODULE = WhatToday::GitWrapper

  def test_can_create_exec_alias
    s = WhatToday::CommandWrapper.new
    s.exec_alias( "echo", 'echo' )
    r = s.echo "hello world"
    assert_equal "hello world", r.chomp
  end

  def test_can_create_shell_alias
    s = WhatToday::CommandWrapper.new
    s.shell_alias( "echo", 'echo' )
    r = s.echo "hello world"
    assert r
  end

  def test_can_create_exec_aliases_from_module_methods
    m = TEST_MODULE
    s = WhatToday::CommandWrapper.for m

    s.include_module_as_exec_aliases m
    assert m.public_instance_methods.
            select { |m| ! s.methods.include? m }.
            empty?

  end

  def test_cannot_create_exec_aliases_from_methods_of_unrequired_modules
    s = WhatToday::CommandWrapper.new
    refute defined?(NonExistentModule)
    assert_raises("cannot include module that has not been required") {
      s.include_module_as_exec_aliases NonExistentModule
    }
  end

end
