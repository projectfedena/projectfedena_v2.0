
pdf.header pdf.margin_box.top_left do
logo = "#{RAILS_ROOT}/public/images/uploads/school logo.jpg"
pdf.image logo, :position=>:left, :height=>50, :width=>50
      pdf.font "Helvetica" do
      info = [
        [ @institute_name.config_value],
        ["Examination Result"],
        ["Class: #{@exm.subject.course.name}"],
        ["Exam: #{@exm.examination_type.name}"]]
pdf.table info, :width => 500,
                :align => {0 => :left},
                :position => :left,
                :border_color => "FFFFFF"
      pdf.move_down(10)
      pdf.stroke_horizontal_rule
        end
end

pdf.move_down(220)

students_data = @students.map do |r|
                x = ExaminationResult.find_by_examination_id_and_student_id(@exm.id, r.id);
                @i = @i+1;
unless x.nil?
unless x.grading.nil?
                [@i,r.full_name,x.marks,@exm.max_marks,x.grading.name]
else
[@i,r.full_name,x.marks,@exm.max_marks,"-"]
end
else
[@i,r.full_name,"-",@exm.max_marks,"-"]
end
end


pdf.table students_data, :border_style => :grid,
                         :headers => ["Sl","Name","Marks Obtained","Max. Marks","Grade"],
                         :header_color => 'BBBBBB',
                         :table_header_style => :bold,
                         :row_colors => ["DDDDDD", "FFFFFF"],
                         :align => { 0 => :left, 1 => :left, 2 => :left,3 => :left,4 => :left },
                         :position => :center,
                         :width =>500,
                         :border_width=>1



pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
     pdf.font "Helvetica" do
        signature = [["Signature"]]
        pdf.table signature, :width => 500,
                :align => {0 => :right},
                :border_color => "FFFFFF",
                :position => :center
        pdf.move_down(20)
        pdf.stroke_horizontal_rule
    end
end

