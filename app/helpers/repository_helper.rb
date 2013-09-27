module RepositoryHelper

  def basepath(path)
    splitpath = path.split('/')
    
    (splitpath[0..-2] << splitpath[-1].split('.')[0]).join('/')
  end

  def group_commits(commits)
    commits.group_by { |c| c[:committer][:time].strftime("%d.%m.%Y") }.map { |k, v| {commits: v, date: k} }
  end

  def get_message(commit)
    title = commit[:message].split("\n").first
    short_title = word_wrap(title, line_width: 80)
    body = commit[:message].split("\n")[1..-1].join("\n")
    if short_title != title
      parts = short_title.split("\n")
      short_title = "#{parts[0]}..."
      body = "#{parts[1..-1].join("\n")}\n#{body}"
    end

    {
      title: title,
      body: body
    }
  end

  def short_oid(commit)
    commit[:oid][0..6]
  end

  def fancy_repository_path(repository, params)
    params ||= {}
    action = params[:action] || :files
    if (params[:oid].nil? || repository.is_head?(params[:oid])) && action == :files
      repository_files_path id: repository, path: params[:path]
    else
      repository_oid_path repository_id: repository, oid: params[:oid], action: action, path: params[:path]
    end
  end

  def repository_history_path(params)
    repository_oid_path(params)
  end
end
