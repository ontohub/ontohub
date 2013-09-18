# Add comments.
5.times do |n|
  c = Ontology.first.comments.build \
    text: (1 + rand(4)).times.map{ Faker::Lorem.paragraph(5 + rand(10)) }.join("\n\n")
  c.user = User.first
  c.created_at = (60 - n * 5).minutes.ago
  c.save!
end
