require_relative './test_helper.rb'

class ShellWrapperTests < MiniTest::Test

  def test_can_use_exec_shell
    s = ShellWrapper.new
    r = s.exec 'echo "hello world"'
    assert_equal "hello world", r.chomp
  end

  def test_can_use_regular_shell
    s = ShellWrapper.new
    r = s.exec 'echo "hello world"'
    assert r
  end

  def test_can_change_dir
    s = ShellWrapper.new
    dir = File.expand_path("../")
    s.working_dir = "../"
    working_dir = s.exec('pwd').chomp
    assert_equal working_dir, dir
  end

  def test_cannot_use_nonexistent_dir
    s = ShellWrapper.new
    dir = "./nonexistent_dir"
    refute File.exist?(dir)
    assert_raises("directory is non-existent") {
      s.working_dir = dir
    }
  end

  def test_can_change_shell
    s = ShellWrapper.new
    shell = '/bin/sh'
    s.preferred_shell = shell
    assert_equal s.preferred_shell, shell
  end

  def test_cannot_change_shell_to_invalid_shell
    s = ShellWrapper.new
    shell = '/bin/something'
    refute File.exist?(shell)
    assert_raises("argument to shell assignment is invalid") {
      s.preferred_shell = shell
    }
  end

end
