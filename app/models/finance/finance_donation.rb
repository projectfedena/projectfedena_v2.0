class FinanceDonation < ActiveRecord::Base
  belongs_to :transaction, :class_name => 'FinanceTransaction'
  validates_presence_of :donor, :amount

  before_save :create_finance_transaction

  def create_finance_transaction
    transaction = FinanceTransaction.create(
      :title => "Donation from " + donor,
      :description => description,
      :amount => amount,
      :category => FinanceTransactionCategory.find_by_name('Donation')
    )
    self.transaction_id = transaction.id
  end
end
