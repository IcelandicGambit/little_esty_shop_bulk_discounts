class BulkDiscount < ApplicationRecord
  validates :name, presence: true
  validates :quantity_threshold, presence: true
  validates :percentage_discount, presence: true

  belongs_to :merchant

  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items


  def discount_percent
    (self.percentage_discount * 100).round
  end

  #pass in AR invoice item, follow chain of bulk discounts for a merchant, grab all discounts for that merchant, 
  def self.determine_discount_applied(invoice_item)
    merchant_discounts_ids = invoice_item.item.merchant.bulk_discounts.pluck(:id)
    possible_discounts = 
      joins(:invoice_items)
      .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
      .where("bulk_discounts.id IN (?)", merchant_discounts_ids)
      .distinct

    # No discount was applied/doesnt meet threshold
    if possible_discounts.size == 0
      return nil 
    end 
    
    best_discount = possible_discounts.first

    # Find the best bulk discount ("max")
    possible_discounts.each do |item|
      if item.percentage_discount > best_discount.percentage_discount
        best_discount = item 
      end
    end
    best_discount
  end
end