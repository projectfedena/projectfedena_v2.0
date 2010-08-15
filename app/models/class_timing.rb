class ClassTiming < ActiveRecord::Base
  has_many :timetable_entries
  belongs_to :batch

  validates_presence_of :name
  
  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i } } }
  named_scope :default, :conditions => { :batch_id => nil, :is_break => false }

  def validate
    errors.add(:end_time, "should be later than start time.") \
      if self.start_time > self.end_time \
      unless self.start_time.nil? or self.end_time.nil?
  end
end
