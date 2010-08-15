class Asset < ActiveRecord::Base
  validates_numericality_of :amount
end
