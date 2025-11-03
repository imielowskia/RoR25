class AddGradeToCourseStudent < ActiveRecord::Migration[8.1]
  def change
    rename_table 'courses_students', 'grades'
    add_column :grades, :grade, :integer
  end
end
