json.array!(@users) do |user|
  json.id user.id
  json.email user.email
  json.name user.name
end
