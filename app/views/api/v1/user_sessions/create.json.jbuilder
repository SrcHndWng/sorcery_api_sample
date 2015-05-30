json.user do |json|
  json.id @user.id
  json.email @user.email
  json.name @user.name
end

json.access_token @access_token