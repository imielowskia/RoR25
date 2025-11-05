class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy grade grade_set grade_save   ]

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
    @students = @group.students
    @grades = []
    @students.each do |s|
      grade = s.grades.where(course_id: @course.id).order(:student_id).first
      if !grade
        xgr = ""
      else
        xgr = grade.grade
      end
      @grades[s.id] = {'imie'=>s.imie, 'nazwisko'=>s.nazwisko, 'grade'=>xgr}
    end
  end

  # GET /course/:id/group/:group_id/grade
  def grade_set
    @group = Group.find(params[:group_id])
    @students = @group.students
    @grades = []
    @students.each do |s|
      grade = s.grades.where(course_id: @course.id).order(:student_id).first
      unless grade
        xgrade = ""
      else
        xgrade = grade.grade
      end
      @grades[s.id] = {'imie'=>s.imie, 'nazwisko'=>s.nazwisko, 'grade'=>xgrade}
    end
  end

  # POST /course/:id/group/:group_id/save
  def grade_save
    @group = Group.find(params[:group_id])
    oceny = params['oceny']
    @group.students.each do |student|
      if student.courses.where(id: @course.id).count()>0
        student.courses.destroy(@course.id)
      end
      @xgr = Grade.new
      @xgr.course_id = @course.id
      @xgr.student_id = student.id
      @xgr.grade = oceny[student.id.to_s].to_i
      @xgr.save
    end
    redirect_to grade_course_path(@course.id, @group.id)
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
      @course = Course.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.expect(course: [ :nazwa, :ects ])
    end
end
