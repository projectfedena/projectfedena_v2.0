class ApplyLeave < ActiveRecord::Base
  validates_presence_of :employee_leave_types_id, :start_date, :end_date, :reason
  belongs_to :employee
  
  cattr_reader :per_page
  @@per_page = 12
  
end
