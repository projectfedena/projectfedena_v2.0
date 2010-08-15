class Attendance < ActiveRecord::Base
  belongs_to :subject
  has_and_belongs_to_many :students
  validates_uniqueness_of :student_id, :scope => [:period_table_entry_id]
end
