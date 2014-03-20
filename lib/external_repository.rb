class ExternalRepository
  extend UriFetcher

  class << self

    def repository
      Repository.where(name: Settings.external_repository_name).first_or_create
    end

    def add_to_repository(iri, message, user, location: iri)
      tmp_path = download_iri(location)
      repository.save_file_only(tmp_path, determine_path(iri, :fullpath),
                                message, user)
    end

    def determine_iri(external_iri)
      "http://#{Settings.hostname}/#{repository.path}/#{determine_path(external_iri, :fullpath)}"
    end

    def determine_path(external_iri, symbol)
      case symbol
      when :fullpath then determine_filepath(external_iri)
      when :dirpath then determine_filepath(external_iri, false)
      when :basepath then determine_basepath(external_iri, false)
      when :basename then determine_basename(external_iri, false)
      when :extension then determine_extension(external_iri)
      else nil
      end
    end

    private
    def determine_filepath(external_iri, with_file=true)
      fullpath = iri_split(external_iri)
      with_file ? fullpath : fullpath.sub(determine_basename(external_iri), '')
    end

    def determine_basepath(external_iri, with_extension=true)
      basepath = iri_split(external_iri)
      with_extension ? basepath : basepath.sub(determine_extension(external_iri), '')
    end

    def determine_basename(external_iri, with_extension=true)
      File.basename(determine_basepath(external_iri, with_extension))
    end

    def determine_extension(external_iri)
      File.extname(determine_basepath(external_iri))
    end

    # split iri into wget -r style
    def iri_split(iri)
      match = URI::regexp(['http','https']).match(iri)
      if match
        host = match[4]
        path = match[7]
        File.join(host, path)
      else
        iri
      end
    end

    def download_iri(external_iri)
      dir = Pathname.new('/tmp/reference_ontologies/').
        join(determine_path(external_iri, :dirpath))
      ensure_path_existence(dir)
      filepath = dir.join(determine_basename(external_iri))
      fetch_uri_content(external_iri, write_file: filepath)
      filepath
    end

    private
    def ensure_path_existence(directory)
      directory.mkpath
    rescue
      nil
    end

  end

end
