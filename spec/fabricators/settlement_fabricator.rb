Fabricator(:settlement) do
  amount  { 100 }
  paid_at { Time.current.change(usec: 0) }
end
