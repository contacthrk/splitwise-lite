Fabricator(:expense) do
  amount      { 100 }
  paid_at     { Time.current.change(usec: 0) }
  description { Faker::Name.name }
end
