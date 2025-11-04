class CreateGradeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :grade_details do |t|
      t.references :course, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.decimal :grade, precision: 3, scale: 2, null: false
      t.date :data

      t.timestamps
    end
  end
end
