class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :album
      t.string :imie
      t.string :nazwisko
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
