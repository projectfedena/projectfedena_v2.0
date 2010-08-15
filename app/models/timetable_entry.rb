class TimetableEntry < ActiveRecord::Base
  belongs_to :course
  belongs_to :class_timing
  belongs_to :subject
  belongs_to :employee
end