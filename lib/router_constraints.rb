class RouterConstraint
  def params(request)
    request.send(:env)["action_dispatch.request.path_parameters"]
  end

  def set_path_parameters(request, new_params)
    params = params(request)
    controller = params[:controller]
    action     = params[:action]

    params.except!(*params.keys).merge!(
      controller: controller,
      action:     action).merge!(new_params)
  end

  def add_path_parameters(request, add_params)
    set_path_parameters(request, params(request).merge(add_params))
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

class LocIdRouterConstraint < RouterConstraint
  ELEMENTS_CACHE_CLEARING_INTERVAL = 1.minute
  @elements_cache_clear_at = Time.now + ELEMENTS_CACHE_CLEARING_INTERVAL
  @elements_cache = {}

  def initialize(find_in_klass, **map)
    @find_in_klass = find_in_klass
    @map = map
    super()
  end

  def matches?(request, path = nil)
    path ||= Journey::Router::Utils.
      unescape_uri(request.original_fullpath)
    # retrieves the hierarchy and member portions of loc/id's
    hierarchy_member = path.split('?', 2).first.split('///', 2).first
    element =
      elements_cache[hierarchy_member] ||
      LocIdBaseModel.find_with_locid(hierarchy_member)

    if element.is_a?(@find_in_klass)
      elements_cache.delete(hierarchy_member)
      clear_elements_cache if elements_cache_clearing_scheduled?
      assign_path_parameters(request, element)

      true
    else
      if !elements_cache.key?(hierarchy_member) && element
        elements_cache[hierarchy_member] = element
      end
      false
    end
  end

  def elements_cache
    self.class.instance_variable_get(:@elements_cache)
  end

  # To keep the memory footprint low in case of unproper removal of cached
  # elements, we clear the cache periodically. This prevents memory leaks.
  def clear_elements_cache
    next_clearing = Time.now + ELEMENTS_CACHE_CLEARING_INTERVAL
    self.class.instance_variable_set(:@elements_cache_clear_at, next_clearing)

    self.class.instance_variable_set(:@elements_cache, {})
  end

  def elements_cache_clearing_scheduled?
    Time.now > self.class.instance_variable_get(:@elements_cache_clear_at)
  end

  def assign_path_parameters(request, element)
    ontology = element.is_a?(Ontology) ? element : element.ontology

    proof_attempt = element.proof_attempt if @map[:proof_attempt]
    theorem = element.theorem if @map[:theorem]

    path_params = {repository_id: ontology.repository.to_param}
    %i(proof_attempt theorem ontology element).each do |p|
      path_params[@map[p]] = binding.local_variable_get(p).id if @map[p]
    end

    add_path_parameters(request, path_params)
  end
end

class RefLocIdRouterConstraint < LocIdRouterConstraint
  def matches?(request)
    params = params(request)
    result = OntologyVersionFinder.
      applicable_reference?(params[:reference])
    path = Journey::Router::Utils.unescape_uri(request.original_fullpath)
    result && update_version_id!(request, path.dup)
  end

  def update_version_id!(request, path)
    version = OntologyVersionFinder.find(path)
    version_id = version.try(:to_param)
    ontology_id = version.try(:ontology).try(:to_param)
    add_path_parameters(request, id: version_id, ontology_id: ontology_id)
    !! version_id
  end
end

class MMTRouterConstraint < LocIdRouterConstraint
  def matches?(request)
    path = request.original_fullpath.
      # Convert MMT to standard Loc/Id
      gsub(/\?+/, '//').
      # Prune ref-portion
      sub('/ref/mmt', '')
    super(request, path)
  end
end

class IRIRouterConstraint < RouterConstraint
  def matches?(request, path = nil)
    path ||= Journey::Router::Utils.
      unescape_uri(request.original_fullpath)
    ontology = Ontology.find_with_iri(path)
    result = !ontology.nil?

    if result
      set_path_parameters(request,
        repository_id: ontology.repository.to_param, id: ontology.id)
    end

    return result
  end
end

class RefIRIRouterConstraint < IRIRouterConstraint
  def matches?(request)
    # remove the ref/:version_number portion from path
    path = Journey::Router::Utils.unescape_uri(request.original_fullpath).
      sub(%r{\A/ref/\d+/}, '')

    super(request, path)
  end
end

class MIMERouterConstraint < RouterConstraint
  attr_accessor :mime_types

  def initialize(*mime_types)
    self.mime_types = mime_types.flatten.map { |m| Mime::Type.lookup(m) }
    super()
  end

  # In some cases request.accepts == [nil] (e.g. cucumber tests),
  # in these cases we will default to true.
  def matches?(request)
    highest_mime = request.accepts.first
    highest_mime ? mime_types.any? { |m| highest_mime == m } : true
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
