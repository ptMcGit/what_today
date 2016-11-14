module GitWrapper

  def self.git_version
    "git --version"
  end

  def self.git_status
    "git status"
  end

  def self.git_status_s
    "git status -s"
  end

end
