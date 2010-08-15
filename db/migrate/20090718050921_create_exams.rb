class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.references :exam_group
      t.references :subject
      t.datetime   :start_time
      t.datetime   :end_time
      t.integer    :maximum_marks
      t.integer    :minimum_marks
      t.references :grading_level
      t.integer    :weightage, :default => 0

      t.references :event
      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end

end
