class CreateUserDepartments < ActiveRecord::Migration
  def change
    create_table :user_departments do |t|
      t.integer :user_id
      t.integer :department_id

      t.timestamps null: false
    end
  end
end
