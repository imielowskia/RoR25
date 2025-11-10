# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# Uruchom: bin/rails db:seed

ActiveRecord::Base.transaction do
  puts "Seeding fields..."
  fields = {
    "Informatyka" => ["INF-A", "INF-B"],
    "Matematyka" => ["MAT-A"],
    "Fizyka" => ["FIZ-A"]
  }

  created_fields = {}

  fields.each do |field_name, group_names|
    f = Field.find_or_create_by!(nazwa: field_name)
    created_fields[field_name] = f

    group_names.each do |group_name|
      g = Group.find_or_create_by!(nazwa: group_name) do |gg|
        gg.field = f
      end
      # ensure association to field is set even if group existed before
      if g.field_id != f.id
        g.update!(field: f)
      end
    end
  end

  puts "Seeding courses..."
  courses_data = [
    { nazwa: "Programowanie 1", ects: 5 },
    { nazwa: "Algebra", ects: 4 },
    { nazwa: "Fizyka I", ects: 3 }
  ]

  # Tworzymy kursy (nie przypisujemy zmiennej, aby nie mieć ostrzeżenia o nieużywanej zmiennej)
  courses_data.each do |attrs|
    Course.find_or_create_by!(nazwa: attrs[:nazwa]) do |c|
      c.ects = attrs[:ects]
    end
  end

  # Przydzielamy kursy do grup (has_and_belongs_to_many)
  puts "Linking courses to groups..."
  # przykładowe powiązania: Programowanie 1 -> wszystkie grupy informatyczne
  prog = Course.find_by(nazwa: "Programowanie 1")
  algebra = Course.find_by(nazwa: "Algebra")
  fizyka = Course.find_by(nazwa: "Fizyka I")

  if prog
    Group.where(nazwa: ["INF-A", "INF-B"]).find_each do |group|
      unless group.courses.exists?(prog.id)
        group.courses << prog
      end
    end
  else
    puts "Uwaga: kurs 'Programowanie 1' nie istnieje - pomijam przypisania do grup"
  end

  if algebra
    Group.where(nazwa: ["MAT-A"]).find_each do |group|
      unless group.courses.exists?(algebra.id)
        group.courses << algebra
      end
    end
  else
    puts "Uwaga: kurs 'Algebra' nie istnieje - pomijam przypisania do grup"
  end

  if fizyka
    Group.where(nazwa: ["FIZ-A"]).find_each do |group|
      unless group.courses.exists?(fizyka.id)
        group.courses << fizyka
      end
    end
  else
    puts "Uwaga: kurs 'Fizyka I' nie istnieje - pomijam przypisania do grup"
  end

  puts "Seeding students..."
  # Utwórz kilka studentów (album musi być unikalny)
  students_data = [
    { album: "2025001", imie: "Jan", nazwisko: "Kowalski", group_nazwa: "INF-A" },
    { album: "2025002", imie: "Anna", nazwisko: "Nowak", group_nazwa: "INF-A" },
    { album: "2025003", imie: "Piotr", nazwisko: "Zalewski", group_nazwa: "MAT-A" },
    { album: "2025004", imie: "Ewa", nazwisko: "Kaczmarek", group_nazwa: "FIZ-A" }
  ]

  created_students = {}
  students_data.each do |s|
    group = Group.find_by(nazwa: s[:group_nazwa])
    raise "Brak grupy #{s[:group_nazwa]}" unless group

    student = Student.find_or_create_by!(album: s[:album]) do |st|
      st.imie = s[:imie]
      st.nazwisko = s[:nazwisko]
      st.group = group
    end

    # upewnij się, że student jest przypisany do właściwej grupy
    if student.group_id != group.id
      student.update!(group: group)
    end

    created_students[s[:album]] = student
  end

  puts "Seeding grades..."
  # Przykladowe oceny (Grade jest tabelą bez id; używamy find_or_initialize_by)
  # Nadajemy oceny tylko tam, gdzie ma to sens.
  grades_data = [
    { album: "2025001", course_nazwa: "Programowanie 1", grade: 5 },
    { album: "2025002", course_nazwa: "Programowanie 1", grade: 4 },
    { album: "2025003", course_nazwa: "Algebra", grade: 3 },
    { album: "2025004", course_nazwa: "Fizyka I", grade: 4 }
  ]

  grades_data.each do |g|
    student = Student.find_by(album: g[:album])
    course = Course.find_by(nazwa: g[:course_nazwa])
    next unless student && course

    grade_record = Grade.find_or_initialize_by(student_id: student.id, course_id: course.id)
    grade_record.grade = g[:grade]
    grade_record.save!
  end

  puts "Seeding grade_details..."
  # Przykładowe szczegóły ocen - tworzymy kilka wpisów z datami. Używamy find_or_initialize_by po student_id, course_id i dacie, aby seedy były idempotentne.
  grade_details_data = [
    { album: "2025001", course_nazwa: "Programowanie 1", grade: 4.50, data: Date.today - 30 },
    { album: "2025001", course_nazwa: "Programowanie 1", grade: 5.00, data: Date.today - 10 },
    { album: "2025002", course_nazwa: "Programowanie 1", grade: 4.00, data: Date.today - 20 },
    { album: "2025003", course_nazwa: "Algebra", grade: 3.50, data: Date.today - 15 },
    { album: "2025004", course_nazwa: "Fizyka I", grade: 4.00, data: Date.today - 5 }
  ]

  grade_details_data.each do |gd|
    student = Student.find_by(album: gd[:album])
    course = Course.find_by(nazwa: gd[:course_nazwa])
    next unless student && course

    gd_record = GradeDetail.find_or_initialize_by(student_id: student.id, course_id: course.id, data: gd[:data])
    gd_record.grade = gd[:grade]
    gd_record.save!
  end

  puts "Done seeding."
end
