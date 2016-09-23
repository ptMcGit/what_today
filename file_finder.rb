class FileFinder
  attr_reader :start_directory, :include_file_types, :exclude_file_types, :name, :results

  def initialize opts={}
    @types
    @start_directory    = opts[:start_directory] ||= "."
    @names              = escape_strings( opts[:names] )
    @include_file_types = opts[:include_file_types]
    @exclude_file_types = opts[:exclude_file_types]
    @ignore_paths       = escape_strings( opts[:ignore_paths] )
    query!
  end

  def escape_strings array
    #binding.pry
    array.map { |i| i.sub(/(.*)/, '\'\1\'') }
  end

  def query!
    @query = prepare_arguments
    #binding.pry
    #%x[ find #{@start_directory} -type d -print0  ].split("\u0000")
    @results = %x[ find #{@query} ].split("\u0000")
  end


  def prepare_arguments
    #binding.pry
    @start_directory + " " +
      prepare_file_args +
      prepare_names +
      prepare_paths
  end

  def prepare_file_args
    includes = []
    excludes = []
    both     = []

    if @include_file_types
      @include_file_types.each do |i|
        includes.push " -type #{i} "
      end
      both.push '\(' + includes.join(" -o ") + '\)'
    end

    if @exclude_file_types
      @exclude_file_types.each do |e|

        excludes.push " ! -type #{e} "
      end
      both.push '\(' + excludes.join(" -o ") + '\)'
    end

    return both.join(" -a " ) if both.any?
    ""
  end

  def prepare_names
    " -name " + @names[0]
  end

  def prepare_paths
    return ' -print0 ' unless @ignore_paths

    ' -a \( ' +

    @ignore_paths.map { |path|
      " -path " + path + " -prune -o "
    }.join +

    ' -print0 \) '

    #' -a \( -path ' + @ignore_paths.join(" -prune -o ") + " -prune -o -print0 " + ' \)'
  end
end
