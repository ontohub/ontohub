# returns up to n unique names
def unique_names(n)
  names= []
  n.times do |x|
    names << Faker::Lorem.word
    names.uniq!
  end
  [names.length, names]
end
