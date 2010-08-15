class EmployeePosition < ActiveRecord::Base
  validates_presence_of :name, :employee_category_id
  validates_uniqueness_of :name

  belongs_to :employee_category
end
