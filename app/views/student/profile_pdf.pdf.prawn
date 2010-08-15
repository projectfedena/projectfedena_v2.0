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
pdf.text @student.full_name , :size => 18 ,:at=>[75,620]
pdf.text "Student Profile" ,:size => 7,:at=>[75,610]



unless @student.student_category.nil?
    cat=@student.student_category.name
else
    cat = " "
end
    pdf.move_down(20)
     data = [["Admission Number" , @student.admission_no],
                 ["Batch" , @student.batch.full_name ],
                 ["Course",(@student.batch.course).course_name],
                ["Date of Birth",@student.date_of_birth.strftime("%d %b, %Y")],
                ["Blood group", @student.blood_group],
                ["Gender",@student.gender_as_text],
                ["Nationality", @student.nationality.name],
                ["Language",@student.language],
                ["Category",cat],
                ["Religion", @student.religion],
                ["Address",@address],
                ["City", @student.city],
                ["State",@student.state],
                ["Country",@student.country.name],
                ["Phone",@student.phone1],
                ["Mobile",@student.phone2],
                ["Email",@student.email]]
unless @immediate_contact.nil?
    data.push ["Immediate contact", @immediate_contact.first_name+" "+@immediate_contact.last_name+ "(" + @immediate_contact.mobile_phone + ")"]
end

            

unless @additional_fields.nil?
@additional_fields.each do |field|
    detail = StudentAdditionalDetails.find_by_additional_field_id_and_student_id(field.id,@student.id)
   unless detail.nil?
     data.push [field.name,detail.additional_info]
   else
         data.push [field.name," "]
   end
end
end


pdf.table data, :width => 500,
                :border_color => "000000",
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
                :column_widths =>{ 0 => 200, 1 => 200},
                :align => { 0 => :left, 1 => :left}


pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
     pdf.font "Helvetica" do
        signature = [[""]]
        pdf.table signature, :width => 500,
                :align => {0 => :right,1 => :right},
                :headers => ["Signature"],
                :header_text_color  => "DDDDDD",
                :border_color => "FFFFFF",
                :position => :center
        pdf.move_down(20)
        pdf.stroke_horizontal_rule
    end
end