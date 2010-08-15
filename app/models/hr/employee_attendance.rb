class EmployeeAttendance < ActiveRecord::Base
  validates_presence_of :employee_leave_type_id
  validates_uniqueness_of :employee_id, :scope=> :attendance_date
  
end
