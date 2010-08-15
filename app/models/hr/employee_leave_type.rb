class EmployeeLeaveType < ActiveRecord::Base

  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code
  validates_numericality_of :max_leave_count
end
