class CreateFinanceFees < ActiveRecord::Migration
  def self.up
    create_table :finance_fees do |t|
      t.references :fee_collection
      t.references :transaction
      t.references :student
    end
  end

  def self.down
    drop_table :finance_fees
  end
end
