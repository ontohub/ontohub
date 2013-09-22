module RepositoryHelper
  
  def basepath(path)
    splitpath = path.split('/')
    
    (splitpath[0..-2] << splitpath[-1].split('.')[0]).join('/')
  end
  
end