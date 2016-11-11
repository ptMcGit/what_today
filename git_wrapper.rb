module GitWrapper

  def git_version
    "git --version"
  end

  def git_status
    "git status"
  end

  def git_status_s
    "git status -s"
  end

end
