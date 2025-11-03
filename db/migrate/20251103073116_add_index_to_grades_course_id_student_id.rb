class AddIndexToGradesCourseIdStudentId < ActiveRecord::Migration[8.1]
  def change
    add_index :grades, [:course_id, :student_id],
              unique: true,
              name: "index_courses_students_on_course_id_and_student_id"
  end
end
