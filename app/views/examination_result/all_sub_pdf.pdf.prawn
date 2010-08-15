
pdf.move_down(40)

student = @students.map do |s|

    pdf.move_down(30)
    name = [[@i,s.full_name]]
    pdf.table name, :width => 200,
                    :align => { 0 => :right},
                  
                    :position => :right,
                    :border_color => "FFFFFF"
            @i = @i+1

    pdf.move_down(20)
    table_header = [["Sub-Code","Marks-obtained","Grade"]]
    pdf.table table_header, :width => 300,
                            :border_color => "000000",
                            :position => :center,
                            :column_widths=>{ 0 => 100, 1 => 100, 2 => 100},
                            :align => { 0 => :left, 1 => :left, 2 => :left},
                            :row_colors => ["CCCCCC"]


    @subjects.each do |sub|
        @res.each do |res|
            if res.student_id == s.id and res.examination.subject_id == sub.id
                data = [[sub.code,res.marks,res.grading.name]]
                    pdf.table data, :width => 300,
                                    :border_color => "000000",
                                    :position => :center,
                                    :row_colors => ["FFFFFF","DDDDDD"],
                                    :column_widths =>{ 0 => 100, 1 => 100, 2 => 100},
                                    :align => { 0 => :left, 1 => :left, 2 => :left}
            end
           
        end
    end
    pdf.move_down(28)
end





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