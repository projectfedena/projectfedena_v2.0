class FinanceFeeCategory < ActiveRecord::Base
  belongs_to :batch
  belongs_to :student
  
  has_many   :fee_particulars, :class_name => "FinanceFeeParticulars"
  has_many   :fee_collections, :class_name => "FinanceFeeCollection"

  cattr_reader :per_page

  validates_presence_of :name

  def fees(student)
    FinanceFeeParticulars.find_all_by_finance_fee_category_id(self.id,
      :conditions => ["is_deleted=false AND (student_category_id IS NULL AND admission_no IS NULL )OR(student_category_id = '#{student.student_category_id}'AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = '#{student.admission_no}')"])
  end
  
  def check_fee_collection
    fee_collection = FinanceFeeCollection.find_all_by_fee_category_id(self.id)
    fee_collection.empty? ? true : false
  end

  def check_fee_collection_for_additional_fees
    flag =0
    fee_collection = FinanceFeeCollection.find_all_by_fee_category_id(self.id)
    fee_collection.each do |fee|
       flag = 1 if fee.check_fee_category == true
    end
    flag == 1 ?  true : false
    
  end

  def delete_particulars
     self.fee_particulars.each do |fees|
       fees.update_attributes(:is_deleted => true)
     end
  end
    
  @@per_page = 10
  
end
