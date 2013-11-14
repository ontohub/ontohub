### Import License Models

@names = %w( GPL GPLv2 GPLv3 LGPL Apache MIT BSD )

@names.length.times do |n|
  LicenseModel.create! \
    name:           @names.slice!(-1),
    description:    Faker::Lorem.sentence,
    url:            Faker::Internet.url
end

Ontology.all.each do |o|
  o.license_model_id = rand(LicenseModel.count)+1
  o.save!
end
