class AddFieldToGroup < ActiveRecord::Migration[8.1]
  def change
    add_reference :groups, :field, null: false, foreign_key: true
  end
end
