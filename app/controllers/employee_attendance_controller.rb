class EmployeeAttendanceController < ApplicationController
  before_filter :login_required,:configuration_settings_for_hr
  before_filter :protect_leave_dashboard, :only => [:leaves, :employee_attendance_pdf]
  before_filter :protect_applied_leave, :only => [:own_leave_application, :cancel_application]
  before_filter :protect_manager_leave_application_view, :only => [:leave_application]
  prawnto :prawn => {:left_margin => 25, :right_margin => 25}

  filter_access_to :all

  def add_leave_types
    @leave_types = EmployeeLeaveType.find(:all, :order => "name ASC")
    @leave_type = EmployeeLeaveType.new(params[:leave_type])
    if request.post? and @leave_type.save
      flash[:notice] = "Employee leave type saved"
      redirect_to :action => "add_leave_types"
    end
  end

  def edit_leave_types
    @leave_type = EmployeeLeaveType.find(params[:id])
    if request.post? and @leave_type.update_attributes(params[:leave_type])
      flash[:notice] = "Leave type updated"
      redirect_to :action => "add_leave_types"
    end
  end

  def register
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true", :order=> "name ASC")
    if request.post?
      unless params[:employee_attendance].nil?
        params[:employee_attendance].each_pair do |emp, att|
          @employee_attendance = EmployeeAttendance.create(:attendance_date => params[:date],
            :employees_id => emp, :employee_leave_types_id=> att) unless att == ""
        end
        flash[:notice]="attendance registered"
        redirect_to :controller=>"employee_attendance", :action => "register"
      end
    end
  end

  def update_attendance_form
    @leave_types = EmployeeLeaveType.find(:all, :conditions=>"status = true", :order=>"name ASC")
    if params[:department_id] == ""
      render :update do |page|
        page.replace_html "attendance_form", :text => ""
      end
      return
    end

    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html 'attendance_form', :partial => 'attendance_form'
    end
  end

  def report
    @departments = EmployeeDepartment.find(:all, :conditions => "status = true", :order=> "name ASC")
  end

  def update_attendance_report
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    if params[:department_id] == ""
      render :update do |page|
        page.replace_html "attendance_report", :text => ""
      end
      return
    end
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html "attendance_report", :partial => 'attendance_report'
    end
  end

  def emp_attendance
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      #@total_leaves = @total_leaves + leave_count
    end
  end

  def leaves
    @leave_types = EmployeeLeaveType.find(:all)
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    @total_leave_count = 0
    @reporting_employees.each do |e|
      @app_leaves = ApplyLeave.count(:conditions=>["employee_id =? AND viewed_by_manager =?", e.id, false])
      @total_leave_count = @total_leave_count + @app_leaves
    end

    @leave_apply = ApplyLeave.new(params[:leave_apply])
    if request.post? and @leave_apply.save
      ApplyLeave.update(@leave_apply, :approved=> false, :viewed_by_manager=> false)
      if params[:is_half_day]
        ApplyLeave.update(@leave_apply, :is_half_day=> true)
      else
        ApplyLeave.update(@leave_apply, :is_half_day=> false)
      end
      flash[:notice]="Leave application created"
      redirect_to :controller => "employee_attendance", :action=> "leaves", :id=>@employee.id
    end
  end

  def leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @manager = @applied_employee.reporting_manager_id
  end

  def leave_app
    @employee = Employee.find(params[:id2])
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
  end

  def approve_remarks
    @applied_leave = ApplyLeave.find(params[:id])
    render :partial=> "approve_remark_form"
  end

  def deny_remarks
    @applied_leave = ApplyLeave.find(params[:id])
    render :partial=> "deny_remark_form"
  end

  def approve_leave
    @applied_leave = ApplyLeave.find(params[:applied_leave])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
    ApplyLeave.update(@applied_leave, :approved => true, :viewed_by_manager => true, :manager_remark => params[:manager_remark])
    start_date = @applied_leave.start_date
    end_date = @applied_leave.end_date
    (start_date..end_date).each do |d|
      unless(d.strftime('%A') == "Sunday")
        EmployeeAttendance.create(:attendance_date=>d, :employee_id=>@applied_employee.id,:employee_leave_type_id=>@applied_leave.employee_leave_types_id, :reason => @applied_leave.reason, :is_half_day => @applied_leave.is_half_day)
        att = EmployeeAttendance.find_by_attendance_date(d)
        EmployeeAttendance.update(att.id, :is_half_day => @applied_leave.is_half_day)
      end
    end
    
    flash[:notice]="Leave approved for #{@applied_employee.first_name} from #{@applied_leave.start_date} to #{@applied_leave.end_date}"
    redirect_to :controller=>"employee_attendance", :action=>"leaves", :id=>@manager
  end

  def deny_leave
    @applied_leave = ApplyLeave.find(params[:applied_leave])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
    ApplyLeave.update(@applied_leave, :viewed_by_manager => true, :manager_remark =>params[:manager_remark])
    flash[:notice]="Leave denied for #{@applied_employee.first_name} from #{@applied_leave.start_date} to #{@applied_leave.end_date}"
    redirect_to :action=>"leaves", :id=>@manager
  end

  def cancel
    render :text=>""
  end

  def new_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "new_leave_applications"
  end

  def all_employee_new_leave_applications
    @employee = Employee.find(params[:id])
    @all_employees = Employee.find(:all)
    render :partial => "all_employee_new_leave_applications"
  end

  def all_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "all_leave_applications"
  end

  def individual_leave_applications
    @employee = Employee.find(params[:id])
    @pending_applied_leaves = ApplyLeave.find_all_by_employee_id(@employee.id, :conditions=> "approved = false AND viewed_by_manager = false", :order=>"start_date DESC")
    @applied_leaves = ApplyLeave.paginate(:page => params[:page],  :conditions=>[ "employee_id = '#{@employee.id}'"], :order=>"start_date DESC")
    render :partial => "individual_leave_applications"
  end

  def own_leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @employee = Employee.find(@applied_leave.employee_id)
  end

  def cancel_application
    @applied_leave = ApplyLeave.find(params[:id])
    @employee = Employee.find(@applied_leave.employee_id)
    ApplyLeave.destroy(params[:id])
    flash[:notice] = "Leave application deleted"
    redirect_to :action=>"leaves", :id=>@employee.id
  end

  def update_all_application_view
    if params[:employee_id] == ""
      render :update do |page|
        page.replace_html "all-application-view", :text => ""
      end
      return
    end
    @employee = Employee.find(params[:employee_id])

    @all_pending_applied_leaves = ApplyLeave.find_all_by_employee_id(params[:employee_id], :conditions=> "approved = false AND viewed_by_manager = false", :order=>"start_date DESC")
    @all_applied_leaves = ApplyLeave.paginate(:page => params[:page],  :conditions=> ["employee_id = '#{@employee.id}'"], :order=>"start_date DESC")
    render :update do |page|
      page.replace_html "all-application-view", :partial => "all_leave_application_lists"
    end
  end

  #PDF Methods

  def employee_attendance_pdf
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      @total_leaves = @total_leaves + leave_count
    end

    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end
end
