class CreateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :fields do |t|
      t.string :nazwa

      t.timestamps
    end
  end
end
