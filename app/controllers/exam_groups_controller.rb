class ExamGroupsController < ApplicationController
  before_filter :initial_queries
  filter_access_to :all
  in_place_edit_for :exam_group, :name

  in_place_edit_for :exam, :maximum_marks
  in_place_edit_for :exam, :minimum_marks
  in_place_edit_for :exam, :weightage

  def index
    @exam_groups = @batch.exam_groups
  end

  def new

  end

  def create
    @exam_group = ExamGroup.new(params[:exam_group])
    @exam_group.batch_id = @batch.id
    if @exam_group.save
      flash[:notice] = 'Exam group created successfully.'
      redirect_to batch_exam_groups_path(@batch)
    else
      render 'new'
    end
  end

  def edit
    @exam_group = ExamGroup.find params[:id]
  end

  def update
    @exam_group = ExamGroup.find params[:id]
    if @exam_group.update_attributes(params[:exam_group])
      flash[:notice] = 'Updated exam group successfully.'
      redirect_to [@batch, @exam_group]
    else
      render 'edit'
    end
  end

  def destroy
    @exam_group = ExamGroup.find(params[:id])
    @exam_group.destroy
    redirect_to [@batch, @exam_groups]
  end

  def show
    @exam_group = ExamGroup.find(params[:id], :include => :exams)
  end

  private
  def initial_queries
    @batch = Batch.find params[:batch_id], :include => :course unless params[:batch_id].nil?
    @course = @batch.course unless @batch.nil?
  end

end