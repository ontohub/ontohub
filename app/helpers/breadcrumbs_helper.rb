module BreadcrumbsHelper

  def repository_breadcrumbs(repository, path, oid)
    path ||= ''
    crumbs = path.split('/')
    result = [{
        name: repository.name,
        last: false,
        path: fancy_repository_path(repository, path: nil, ref: oid)
    }]

    crumbs.each_with_index do | c, i |
      segment = crumbs[0..i].join('/')
      result << {
        name: c,
        last: false,
        path: fancy_repository_path(repository, path: segment, ref: oid)
      }
    end

    result.last[:last] = true

    result
  end

end
