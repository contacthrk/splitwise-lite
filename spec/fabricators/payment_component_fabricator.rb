Fabricator(:payment_component) do
  amount      { 100 }
  description { Faker::Name.name }
  category    { 'manual' }
  split       { 'equal' }
end
