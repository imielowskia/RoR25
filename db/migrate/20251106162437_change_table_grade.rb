class ChangeTableGrade < ActiveRecord::Migration[8.1]
  def up
    # tworzymy nową tabelę z PK złożonym
    create_table :grades_new, primary_key: %i[course_id student_id] do |t|
      t.integer :course_id, null: false
      t.integer :student_id, null: false
      t.integer :grade
    end

    # kopiujemy istniejące dane
    execute <<~SQL
      INSERT INTO grades_new (course_id, student_id, grade)
      SELECT course_id, student_id, grade             
      FROM grades;
    SQL

    # zamieniamy tabele
    drop_table :grades
    rename_table :grades_new, :grades
  end

  def down
    create_table :grades_old, id: false do |t|
      t.integer :course_id, null: false
      t.integer :student_id, null: false
      t.integer :grade
    end

    execute <<~SQL
      INSERT INTO grades_old (course_id, student_id, grade)
      SELECT course_id, student_id, grade FROM grades;
    SQL

    drop_table :grades
    rename_table :grades_old, :grades
  end

end
