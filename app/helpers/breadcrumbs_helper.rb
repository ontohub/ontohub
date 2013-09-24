module BreadcrumbsHelper
  def repository_breadcrumbs(repository, path, is_head, oid)
    path ||= ''
    crumbs = path.split('/')
    result = [{ 
        name: 'Home',
        last: false,
        path: fancy_repository_files_path(repository, nil, oid)
    }]
      
    crumbs.each_with_index do | c, i |
      segment = crumbs[0..i].join('/')
      result << {
        name: c,
        last: false,
        path: fancy_repository_files_path(repository, segment, oid)
      }
    end
    
    result.last[:last] = true
    
    result
  end
end
