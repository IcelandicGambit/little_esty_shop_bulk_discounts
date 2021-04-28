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
 
    find_discount_by_item = joins(:invoice_items, :bulk_discounts)
      .where('invoice_items.quantity >= bulk_discounts.quantity_threshold AND merchants.id = ?', merchant_id)
      .select("invoice_items.id as ii_id, 
        bulk_discounts.quantity_threshold, 
        bulk_discounts.percentage_discount,
        invoice_items.unit_price, 
        invoice_items.quantity")

        # @ii_1 = InvoiceItem.create!(id: 10, invoice: @invoice_a, item: @item_a, quantity: 10, unit_price: 5, status: :shipped)
        # item 3, 5, 100
        # 


    # Determine the best discount for each customer 
    max_discount_so_far = {}
    find_discount_by_item.each do |item| 
      if max_discount_so_far.key? item.ii_id and item.percentage_discount > max_discount_so_far[item.ii_id].percentage_discount
        max_discount_so_far[item.ii_id] = item
      else
        max_discount_so_far[item.ii_id] = item
      end
    end

    #each item is an active record, each item id is put in the db, compared to the first id. If id is the same, compare discount percentage and take higher.

    # Determine the revenue for the best discount for each invoice item id (ii_id)
    total_discount_revenue = 0 
    total_discount_revenue = max_discount_so_far.inject(0) do |accumulator, (key, item)|
      accumulator += (item.unit_price * item.quantity * (1 - item.percentage_discount))
    end

    # Determine the revenue for non-discounted items. Goes through keys array and eliminates invoice items in discounted hash.
    total_non_discounted_revenue = joins(:invoice_items)
      .where("invoice_items.id NOT IN (?)", max_discount_so_far.keys)
      .where("merchant_id = ?", merchant_id)
      .sum("invoice_items.unit_price * invoice_items.quantity")

    (total_discount_revenue + total_non_discounted_revenue).round(2)
  end
end

  # differences between 1 and 2, similarities. possible to write one query at the exclusion of the other. possible helper methods in refactor. use distinct instead of uniq ACTIVE RECORD
  # lines 71 and 75 could be rolled into 1 query. 
    # 10 * 5 = $50 -- $40
    # 3 * 10 = $30 -- $27
    # 1 * 100 = $100 - $100
    # total = $167
    
    # - invoice_item_id: 1, quantity: 10 <-> quantity_threshold: 3, percentage_discount: .1 keep 
    # - invoice_item_id: 1, quantity: 10 <-> quantity_threshold: 5, percentage_discount: .2 keep 

    # - invoice_item_id: 2, quantity: 3 <-> quantity_threshold: 3, percentage_discount: .2 keep
    # - invoice_item_id: 2, quantity: 3 <-> quantity_threshold: 5, percentage_discount: .2  
    
    # - invoice_item_id: 3, quantity: 1 <-> quantity_threshold: 3, percentage_discount: .2 
    # - invoice_item_id: 3, quantity: 1 <-> quantity_threshold: 5, percentage_discount: .2
    
    # - invoice_item_id: 4, quantity: 10 <-> quantity_threshold: 3, percentage_discount: .2 not belonging to our merchant  -- filter it out on rails associations (where merchant = merchant1)
    # - invoice_item_id: 4, quantity: 10 <-> quantity_threshold: 5, percentage_discount: .2  
    
    # - group by item_id
    # - select max of the quantity_threshold, compute the discount based on quantity * percentage discount 