module RepositoriesHelper

  def clone_methods(visible: nil)
    methods = %w{git ssh-git}
    methods.map! { |method| [method, method == visible]} if visible
    methods
  end

  def clone_method_links
    clone_methods.map do |clone_method|
      link_to clone_method, "##{clone_method}",
        class: 'clone_method_link',
        data: {clone: clone_method}
    end.join(', ')
  end

  def repository_clone_url(repository, clone_type: 'git', port: nil)
    case clone_type
    when 'git'
      repository_tree_url(repository, protocol: 'git', port: nil) << '.git'
    when 'ssh-git'
      "git@#{Settings.hostname}:#{repository.path}.git"
    end
  end

end
