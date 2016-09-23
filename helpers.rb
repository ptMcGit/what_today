module Helpers
  def self.process_directories array_of_dirs
    array_of_dirs.map do |dir|
      %x[ cd #{dir}/../ ; pwd ].chomp
    end
  end

  def self.exec_git_method(destination, method)
    cmd = "cd #{destination}; " + method
    system( cmd )
  end

end
