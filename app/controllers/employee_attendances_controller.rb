class EmployeeAttendancesController < ApplicationController
  before_filter :login_required,:configuration_settings_for_hr
  filter_access_to :all
  
  def index
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true", :order=> "name ASC")
  end

  def show
    @dept = EmployeeDepartment.find(params[:dept_id])
    @employees = Employee.find_all_by_employee_department_id(@dept.id)
    unless params[:next].nil?
      @today = params[:next].to_date
    else
    @today = Date.today
    end
    @start_date = @today.beginning_of_month
    @end_date = @today.end_of_month
     respond_to do |format|
       format.js {render :action => 'show'}
     end
  end

  def new
    @attendance = EmployeeAttendance.new
    @employee = Employee.find(params[:id2])
    @date = params[:id]
    @leave_types = EmployeeLeaveType.find(:all, :conditions=>"status = true", :order=>"name ASC")

    respond_to do |format|
      format.js {render :action => 'new'}
    end
  end

  def create
    @attendance = EmployeeAttendance.new(params[:employee_attendance])
    @employee = Employee.find(params[:employee_attendance][:employee_id])
    @date = params[:employee_attendance][:attendance_date]
    if @attendance.save
      respond_to do |format|
        format.js {render :action => 'create'}
      end
    end
  end

  def edit
    @attendance = EmployeeAttendance.find(params[:id])
    @employee = Employee.find(@attendance.employee_id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions=>"status = true", :order=>"name ASC")
    respond_to do |format|
      format.js {render :action => 'edit'}
    end
  end

  def update
    @attendance = EmployeeAttendance.find params[:id]
    respond_to do |format|
      if @attendance.update_attributes(params[:employee_attendance])
        @employee = Employee.find(@attendance.employee_id)
        @date = @attendance.attendance_date
      end
      format.js {render :action => 'update'}
    end
  end

  def destroy
    @attendance = EmployeeAttendance.find(params[:id])
    @attendance.delete
    respond_to do |format|
      @employee = Employee.find(@attendance.employee_id)
      @date = @attendance.attendance_date
      format.js {render :action => 'update'}
    end
  end
end
