class MonthlyPayslip < ActiveRecord::Base

  validates_presence_of :salary_date

  belongs_to :payroll_category
  belongs_to :approver ,:class_name => 'User'

  def approve(user_id)
    self.is_approved = true
    self.approver_id = user_id
    self.save
  end

  def payslip_count(start_date,end_date)
    
  end


end
