pdf.header pdf.margin_box.top_left do
  if FileTest.exists?("#{RAILS_ROOT}/public/uploads/image/institute_logo.jpg")
    logo = "#{RAILS_ROOT}/public/uploads/image/institute_logo.jpg"
  else
    logo = "#{RAILS_ROOT}/public/images/application/app_fedena_logo.jpg"
  end
  @institute_name=Configuration.get_config_value('InstitutionName');
  @institute_address=Configuration.get_config_value('InstitutionAddress');
  pdf.image logo, :position=>:left, :height=>50, :width=>50
  pdf.font "Helvetica" do
    info = [[@institute_name],
      [@institute_address]]
    pdf.move_up(50)
    pdf.fill_color "97080e"
    pdf.table info, :width => 400,
      :align => {0 => :center},
      :position => :center,
      :border_color => "FFFFFF"
    pdf.move_down(20)
    pdf.stroke_horizontal_rule
  end
end
pdf.move_down(100)
pdf.text "Time Table", :size => 18 ,:align => :center
pdf.text @employee.full_name, :size => 18 ,:align => :center

widths =  {0=>50}

@day.each do |d|
    data = Array.new(){Array.new()}
  timetable_row = Array.new()
  timetable_row.push @weekday[d.weekday.to_i][0,3].upcase
  @period_timing.each do |pt1|
is_teaching=0
subject_name = ""
    tte = TimetableEntry.find_by_week_day_id_and_class_timing_id( d.weekday.to_i,pt1.id)
    unless tte.nil? or tte.subject.nil? or tte.subject_id.nil?
      unless tte.subject.elective_group.nil?
        elective_subjects = Subject.find_all_by_elective_group_id(tte.subject.elective_group.id)
        elective_subjects.each do |esub|
          teacher = EmployeesSubject.find_by_subject_id(esub.id)
          unless teacher.nil?
              if teacher.employee_id==@employee.id
                is_teaching =1
                subject_name=teacher.subject.code
              end
          end
        end
      else
      unless tte.employee.nil?
            if(tte.employee==@employee)
              is_teaching =1
              subject_name = tte.subject.code
            end
       end
      end
      if is_teaching==1

        timeslot = (tte.class_timing.start_time.strftime("%I:%M %p")+" to  "+tte.class_timing.end_time.strftime("%I:%M %p")) unless tte.class_timing.start_time.nil?
        timetable_row.push subject_name+", "+tte.subject.batch.course.full_name+"\n"+timeslot
      end
    end

 end
       if timetable_row.size == 1
      timetable_row.push " - "
    end
 data.push timetable_row
    color = cycle("FFFFFF","DDDDDD")

    pdf.table data, :width => 550,
      :border_color => "000000",
      :header_color => "eeeeee",
      :header_text_color  => "97080e",
      :position => :left,
      :row_colors => [color],
      :align =>  :center,
      :column_widths => {0=>50},
      :font_size => 9
end


