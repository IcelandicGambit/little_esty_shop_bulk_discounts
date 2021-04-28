require 'rails_helper'

RSpec.describe 'invoices show' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @merchant2 = Merchant.create!(name: 'Jewelry')

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant: @merchant1, status: :enabled)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant: @merchant1)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant: @merchant1)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant: @merchant1)
    @item_5 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant: @merchant2)
    @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant: @merchant2)
    @item_7 = Item.create!(name: "Scrunchie", description: "This holds up your hair but is bigger", unit_price: 3, merchant: @merchant1)
    @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant: @merchant1)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Coon')

    @invoice_1 = Invoice.create!(customer: @customer_1, status: :complete)
    @invoice_2 = Invoice.create!(customer: @customer_1, status: :complete)
    @invoice_3 = Invoice.create!(customer: @customer_2, status: :complete)
    @invoice_4 = Invoice.create!(customer: @customer_3, status: :complete)
    @invoice_5 = Invoice.create!(customer: @customer_4, status: :complete)
    @invoice_6 = Invoice.create!(customer: @customer_5, status: :complete)
    @invoice_7 = Invoice.create!(customer: @customer_6, status: :complete)
    @invoice_8 = Invoice.create!(customer: @customer_6, status: :in_progress)

    @ii_1 = InvoiceItem.create!(invoice: @invoice_1, item: @item_1, quantity: 9, unit_price: 10, status: :shipped)
    @ii_2 = InvoiceItem.create!(invoice: @invoice_2, item: @item_1, quantity: 1, unit_price: 10, status: :shipped)
    @ii_3 = InvoiceItem.create!(invoice: @invoice_3, item: @item_2, quantity: 2, unit_price: 8, status: :shipped)
    @ii_4 = InvoiceItem.create!(invoice: @invoice_4, item: @item_3, quantity: 3, unit_price: 5, status: :pending)
    @ii_6 = InvoiceItem.create!(invoice: @invoice_5, item: @item_4, quantity: 1, unit_price: 1, status: :pending)
    @ii_7 = InvoiceItem.create!(invoice: @invoice_6, item: @item_7, quantity: 1, unit_price: 3, status: :pending)
    @ii_8 = InvoiceItem.create!(invoice: @invoice_7, item: @item_8, quantity: 1, unit_price: 5, status: :pending)
    @ii_9 = InvoiceItem.create!(invoice: @invoice_7, item: @item_4, quantity: 1, unit_price: 1, status: :pending)
    @ii_10 = InvoiceItem.create!(invoice: @invoice_8, item: @item_5, quantity: 1, unit_price: 1, status: :pending)
    @ii_11 = InvoiceItem.create!(invoice: @invoice_1, item: @item_8, quantity: 12, unit_price: 6, status: :pending)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: :success, invoice: @invoice_1)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: :success, invoice: @invoice_2)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: :success, invoice: @invoice_3)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: :success, invoice: @invoice_4)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: :success, invoice: @invoice_5)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: :failed, invoice: @invoice_6)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: :success, invoice: @invoice_7)
    @transaction8 = Transaction.create!(credit_card_number: 203942, result: :success, invoice: @invoice_8)
    
    
    # Invoice XYZ -- transaction should be successful 
      # Merchant A has bulk Discount -- Item 1 10% for minimum 3 items, Item 2 20% for minimum 5 items, no discounts for item 3
        # Item A -- Quantity: 10, Price: $5, belongs to merchant A  10%
        # Item B -- Quantity: 5, Price: $10, belongs to merchant A  20%
        # Item C -- Quantity: 1, Price: $100, belongs to merchant A 0%
      # Merchant B has no bulk discount
        # Item D -- Quantity: 10, Price: $10, belongs to merchant B

    @merchant_a = Merchant.create!(name: "Kohl Lamb")
    @merchant_b = Merchant.create!(name: "Taryn Lamb")
    @customer_a = Customer.create!(first_name: 'Sandeep', last_name: 'Patel')
    @item_a = Item.create!(name: "Item A", description: "Item A", unit_price: 5, merchant: @merchant_a)
    @item_b = Item.create!(name: "Item B", description: "Item B", unit_price: 10, merchant: @merchant_a)
    @item_c = Item.create!(name: "Item C", description: "Item C", unit_price: 100, merchant: @merchant_a)
    @item_d = Item.create!(name: "Vegan Bath Bombs", description: "Item D", unit_price: 10, merchant: @merchant_b)

    @invoice_a = Invoice.create!(customer: @customer_a, status: :complete)
    @ii_1 = InvoiceItem.create!(invoice: @invoice_a, item: @item_a, quantity: 10, unit_price: 5, status: :shipped)
    @ii_2 = InvoiceItem.create!(invoice: @invoice_a, item: @item_b, quantity: 3, unit_price: 10, status: :shipped)
    @ii_3 = InvoiceItem.create!(invoice: @invoice_a, item: @item_c, quantity: 1, unit_price: 100, status: :shipped)
    @ii_4 = InvoiceItem.create!(invoice: @invoice_a, item: @item_d, quantity: 10, unit_price: 10, status: :pending)
    @discount_a = BulkDiscount.create!(merchant: @merchant_a, name: "Discount A", quantity_threshold: 3, percentage_discount: 0.1)
    @discount_b = BulkDiscount.create!(merchant: @merchant_a, name: "Discount B", quantity_threshold: 5, percentage_discount: 0.2)

    @transaction_a = Transaction.create!(credit_card_number: 13374206980085, result: :success, invoice: @invoice_a)

    # 10 * 5 = $50 -- $40
    # 3 * 10 = $30 -- $27
    # 1 * 100 = $100 - $100
    
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
  end

  it "shows the invoice information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@invoice_1.id)
    expect(page).to have_content(@invoice_1.status)
    expect(page).to have_content(@invoice_1.created_at.strftime("%A, %B %-d, %Y"))
  end

  it "shows the customer information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@customer_1.first_name)
    expect(page).to have_content(@customer_1.last_name)
    expect(page).to_not have_content(@customer_2.last_name)
  end

  it "shows the item information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_1.unit_price)
    expect(page).to_not have_content(@ii_4.unit_price)

  end

  it "shows the total revenue for this invoice" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@invoice_1.total_revenue)
  end

  it "shows a select field to update the invoice status" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    within("#the-status-#{@ii_1.id}") do
      page.select("cancelled")
      click_button "Update Invoice"
      expect(page).to have_content("cancelled")
      expect(page).to_not have_content("in progress")
     end
  end

  
end
