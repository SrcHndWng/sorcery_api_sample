json.extract! @user, :id, :email, :name

json.department do
  json.id @user.user_department.department_id
  json.name @user.user_department.department.name
end
