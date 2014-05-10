module RepositoriesHelper

  def clone_methods(visible: nil)
    methods = %w{git ssh-git}
    methods.map! { |method| [method, method == visible]} if visible
    methods
  end

# def clone_method_links
#   clone_methods.map do |clone_method|
#     clone_method_link clone_method
#   end.join(', ')
# end

  def clone_method_link(method)
    link_to method, "##{method}", class: 'clone_method_link', data: {clone: method}
  end

  def repository_clone_url(repository, clone_type: 'git', port: nil)
    case clone_type
    when 'git'
      repository_tree_url(repository, protocol: 'git', port: nil) << '.git'
    when 'ssh-git'
      "git@#{Settings.hostname}:#{repository.path}.git"
    end
  end

  def access_change_hint
    t 'repository.access.change_hint' if resource.is_private
  end

  def access_options
    t('repository.access.options').select do |k,v|
      if @repository.remote?
        k.to_s.split('_')[1] == 'r'
      else
        true
      end
    end.invert
  end

end
