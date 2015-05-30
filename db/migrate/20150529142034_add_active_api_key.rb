class AddActiveApiKey < ActiveRecord::Migration
  def change
    add_column :api_keys, :active, :boolean
  end
end
