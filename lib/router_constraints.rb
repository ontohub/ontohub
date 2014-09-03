class RouterConstraint
  def set_path_parameters(request, new_params)
    params     = request.send(:env)["action_dispatch.request.path_parameters"]
    controller = params[:controller]
    action     = params[:action]

    params.except!(*params.keys).merge!(
      controller: controller,
      action:     action).merge!(new_params)
  end
end


class FilesRouterConstraint < RouterConstraint
  def matches?(request)
    return false if Repository.find_by_path(request.params[:repository_id]).nil?

    result = !RepositoryFile.find_with_path(
      params_path_without_format(request)).nil?

    set_params_path_without_format(request) if result

    return result
  end

  protected
  def params_path_without_format(request)
    @params = request.send(:env)["action_dispatch.request.path_parameters"]
    @path   = @params[:path]
    @path  += ".#{@params[:format]}" if @params[:format]

    @params.merge({ path: @path }).except(:format)
  end

  def set_params_path_without_format(request)
    params_path_without_format(request)
    @params.merge!({ path: @path }).except!(:format)
  end
end


class IRIRouterConstraint < RouterConstraint
  def matches?(request)
    ontology = Ontology.find_with_iri(request.original_url)
    result = !ontology.nil?

    if result
      set_path_parameters(request,
        repository_id: ontology.repository.to_param, id: ontology.id)
    end

    return result
  end
end

class MIMERouterConstraint < RouterConstraint
  attr_accessor :mime_types

  def initialize(*mime_types)
    self.mime_types = mime_types.flatten.map { |m| Mime::Type.lookup(m) }
    super()
  end

  def matches?(request)
    mime_types.any? { |m| request.accepts.first == m }
  end
end

class GroupedConstraint
  attr_accessor :constraints

  def initialize(*args)
    self.constraints = args.flatten
  end

  def matches?(request)
    constraints.all? { |c| c.matches?(request) }
  end
end
