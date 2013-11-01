repository = Repository.first!
3.times do |n|
  u = UrlMap.new
  u.repository = repository
  u.source = "source#{n}.com"
  u.target = "target#{n}.com"
  u.save
end
