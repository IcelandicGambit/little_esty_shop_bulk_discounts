class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :bulk_discounts
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  enum status: [:enabled, :disabled]

  def favorite_customers
    transactions
    .joins(invoice: :customer)
    .where('result = ?', 1)
    .select("customers.*, count('transactions.result') as top_result")
    .group('customers.id')
    .order(top_result: :desc)
    .limit(5)
  end

  def ordered_items_to_ship
    item_ids = InvoiceItem.where("status = 0 OR status = 1").order(:created_at).pluck(:item_id)
    item_ids.map do |id|
      Item.find(id)
    end
  end

  def top_5_items
     items
     .joins(invoices: :transactions)
     .where('transactions.result = 1')
     .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
     .group(:id)
     .order('total_revenue desc')
     .limit(5)
   end

  def self.top_merchants
    joins(invoices: [:invoice_items, :transactions])
    .where('result = ?', 1)
    .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .group(:id)
    .order('total_revenue DESC')
    .limit(5)
  end

  def best_day
    invoices
    .where("invoices.status = 2")
    .joins(:invoice_items)
    .select('invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as revenue')
    .group("invoices.created_at")
    .order("revenue desc", "created_at desc")
    .first
    .created_at
    .to_date
  end

  def self.total_revenue_by_merchant(merchant_id)
    # returns invoice item id, the threshold it meets, and the bulkdiscount id
    items_that_are_discounted = joins(:bulk_discounts, :invoice_items)
      .where("invoice_items.quantity >= bulk_discounts.quantity_threshold AND merchants.id = ?", merchant_id)
      .group("invoice_items.id")
      .select("invoice_items.id, max(bulk_discounts.quantity_threshold) as threshold")

    require "pry"; binding.pry 

    discount_revenue = joins(:invoice_items, :bulk_discounts)
      .where("invoice_items.id IN (?) AND merchants.id = ?", items_that_are_discounted.pluck("invoice_items.id").uniq, merchant_id) #strong params sanitation, sql injection
      .select("SUM(invoice_items.quantity * invoice_items.unit_price * bulk_discounts.percentage_discount) as revenue")

    normal_revenue = joins(:invoice_items)
      .where("invoice_items.id NOT IN (?) AND merchants.id = ?", items_that_are_discounted.pluck("invoice_items.id").uniq, merchant_id) #strong params sanitation, sql injection
      .select("SUM(invoice_items.quantity * invoice_items.unit_price) as revenue")

    discount_revenue.to_a.first.revenue + normal_revenue.to_a.first.revenue
  end
end
