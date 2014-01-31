module FilesHelper

  def basepath(path)
    splitpath = path.split('/')

    (splitpath[0..-2] << splitpath[-1].split('.')[0]).join('/')
  end

  def group_commits(commits)
    commits.group_by { |c| c[:committer][:time].strftime("%d.%m.%Y") }.map { |k, v| {commits: v, date: k} }
  end

  def get_message(commit)
    title = commit[:message].split("\n").first
    short_title = word_wrap(title, line_width: 70)
    body = commit[:message].split("\n")[1..-1].join("\n")
    if short_title != title
      parts = short_title.split("\n")
      short_title = "#{parts[0]}..."
      body = "#{parts[1..-1].join("\n")}\n#{body}"
    end

    {
      title: short_title,
      body: body
    }
  end

  def current_commit_id(oid)
    oid[0..6]
  end

  def short_oid(commit)
    commit[:oid][0..6]
  end

  def in_ref_path?
    !params[:ref].nil?
  end

  def history_pagination(commits, current_page, per_page)
    Kaminari.paginate_array(commits, total_count: ensure_next_page_exists(current_page, per_page)).page(current_page).per(per_page)
  end

  def ensure_next_page_exists(current_page, per_page)
    Integer(current_page || 1)*(per_page+1)
  end

  def dirpath(repository)
    return '' if params[:path].nil?
    parts = params[:path].split('/')
    dir = []
    parts.each_with_index do |part, i|
      if repository.dir?(parts[0..i].join('/'))
        dir << part
      end
    end

    dir.join('/')
  end

  def file_exists?
    @info[:type] == :file
  end

  def update_file
    if file_exists?
      { 'upload_file[target_filename]' => @info[:file][:name] }
    else
      { }
    end
  end

end
