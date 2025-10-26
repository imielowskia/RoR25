class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :nazwa
      t.integer :ects

      t.timestamps
    end
  end
end
