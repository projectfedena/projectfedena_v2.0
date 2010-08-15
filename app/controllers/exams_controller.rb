class ExamsController < ApplicationController
  before_filter :query_data
  filter_access_to :all
  def new
    @exam = Exam.new
    @subjects = @batch.subjects
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.exam_group_id = @exam_group.id
    if @exam.save
      flash[:notice] = "New exam created successfully."
      redirect_to [@batch, @exam_group]
    else
      @subjects = @batch.subjects
      render 'new'
    end
  end

  def edit
    @exam = Exam.find params[:id], :include => :exam_group
    @subjects = @exam_group.batch.subjects
  end

  def update
    @exam = Exam.find params[:id], :include => :exam_group

    if @exam.update_attributes(params[:exam])
      flash[:notice] = 'Updated exam details successfully.'
      redirect_to [@exam_group, @exam]
    else
      render 'edit'
    end
  end

  def show
    @exam = Exam.find params[:id], :include => :exam_group
    exam_subject = Subject.find(@exam.subject_id)
    is_elective = exam_subject.elective_group_id
    if is_elective == nil
    @students = @batch.students
    else
      assigned_students = StudentsSubject.find_all_by_subject_id(exam_subject.id)
      @students = []
      assigned_students.each do |s|
        student = Student.find_by_id(s.student_id)
        @students.push student unless student.nil?
      end
    end
    @config = Configuration.get_config_value('ExamResultType') || 'Marks'

    @grades = @batch.grading_level_list
  end

  def destroy
    @exam = Exam.find params[:id], :include => :exam_group
    batch_id = @exam.exam_group.batch_id
    batch_event = BatchEvent.find_by_event_id_and_batch_id(@exam.event_id,batch_id)
    event = Event.find(@exam.event_id)
    event.destroy
    batch_event.destroy
    @exam.destroy
    redirect_to [@batch, @exam_group]
  end

  def save_scores
    @exam = Exam.find(params[:id])
    params[:exam].each_pair do |student_id, details|
      @exam_score = ExamScore.find(:first, :conditions => {:exam_id => @exam.id, :student_id => student_id} )
      if @exam_score.nil?
        ExamScore.create do |score|
          score.exam_id          = @exam.id
          score.student_id       = student_id
          score.marks            = details[:marks]
          score.grading_level_id = details[:grading_level_id]
          score.remarks          = details[:remarks]
        end
      else
        @exam_score.update_attributes(details)
      end
    end
    flash[:notice] = 'Exam scores updated.'
    redirect_to [@exam_group, @exam]
  end

  private
  def query_data
    @exam_group = ExamGroup.find(params[:exam_group_id], :include => :batch)
    @batch = @exam_group.batch
    @course = @batch.course
  end

end
