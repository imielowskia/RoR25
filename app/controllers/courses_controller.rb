class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy grade grade_set grade_save grade_details grade_details_set grade_details_save blank ]

  # GET /courses or /courses.json
  def index
    @courses = Course.all
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # GET /course/:id/group/:group_id
  def grade
    @group = Group.find(params[:group_id])
    # sortuj studentów dla stabilnego wyświetlania
    @students = @group.students.order(:nazwisko, :imie)
    @grades = {}
    @students.each do |s|
      grade = s.grades.where(course_id: @course.id).order(:student_id).first
      xgr = grade ? grade.grade : ""
      @grades[s.id] = { 'imie' => s.imie, 'nazwisko' => s.nazwisko, 'grade' => xgr }
    end
  end

  # GET /course/:id/group/:group_id/grade
  def grade_set
    @group = Group.find(params[:group_id])
    @students = @group.students.order(:nazwisko, :imie)
    @grades = {}
    @students.each do |s|
      grade = s.grades.where(course_id: @course.id).order(:student_id).first
      xgrade = grade ? grade.grade : ""
      @grades[s.id] = { 'imie' => s.imie, 'nazwisko' => s.nazwisko, 'grade' => xgrade }
    end
  end

  # POST /course/:id/group/:group_id/save
  def grade_save
    @group = Group.find(params[:group_id])
    oceny = params['oceny'] || {}

    ActiveRecord::Base.transaction do
      @group.students.each do |student|
        val = (oceny[student.id.to_s] || "").to_i
        # jeśli wartość 0 lub pusta => usuń istniejącą ocenę
        existing = Grade.find_by(course_id: @course.id, student_id: student.id)
        if val <= 0
          existing.destroy if existing
        else
          g = existing || Grade.new(course_id: @course.id, student_id: student.id)
          g.grade = val
          g.save!
        end
      end
    end

    redirect_to grade_course_path(@course.id, @group.id)
  end

  #GET /course/:id/group/:group_id/details
  def grade_details
    @group = Group.find(params[:group_id])
    @students = @group.students.order(:nazwisko, :imie)
    @details = {}
    @students.each do |student|
      xgrad = []
      details = student.grade_details.where(course_id: @course.id).order(:id)
      if details.empty?
        xgrad << { 'id' => 0, 'grade' => 0 }
      else
        details.each do |d|
          xgrad << { 'id' => d.id, 'grade' => d.grade }
        end
      end
      @details[student.id] = { 'imie' => student.imie, 'nazwisko' => student.nazwisko, 'details' => xgrad }
    end
  end


    #GET /course/:id/group/:group_id/grade_details
    def grade_details_set
      @group = Group.find(params[:group_id])
      @students = @group.students.order(:nazwisko, :imie)
      @details = {}
      @students.each do |student|
        xgrad = []
        details = student.grade_details.where(course_id: @course.id).order(:id)
        if details.present?
          details.each do |d|
            xgrad << { 'id' => d.id, 'grade' => d.grade }
          end
        end
        # dodaj jedno puste pole do formularza (id: 0 -> nowy rekord)
        xgrad << { 'id' => 0, 'grade' => 0 }
        @details[student.id] = { 'imie' => student.imie, 'nazwisko' => student.nazwisko, 'details' => xgrad }
      end
    end



#POST /course/:id/group/:group_id/grade_details_save
def grade_details_save
  @group = Group.find(params[:group_id])
  oceny = params['oceny'] || {}

  ActiveRecord::Base.transaction do
    @group.students.each do |student|
      details = oceny[student.id.to_s] || {}
      # details może być nil gdy formularz nie przesyła nic dla studenta
      details.each do |id_str, grade_val|
        next if grade_val.blank?
        grade_i = grade_val.to_i
        next if grade_i <= 0

        id_i = id_str.to_i
        if id_i == 0
          gd = GradeDetail.new(course_id: @course.id, student_id: student.id, grade: grade_i)
          gd.save!
        else
          gd = GradeDetail.find_by(id: id_i)
          # upewnij się, że rekord należy do tego studenta i kursu
          if gd && gd.student_id == student.id && gd.course_id == @course.id
            gd.grade = grade_i
            gd.save!
          end
        end
      end
    end
  end

  redirect_to grade_details_course_path(@course.id, @group.id)

end


def blank

end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: "Course was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:nazwa, :ects)
    end
end
