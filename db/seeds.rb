@merchant_a = Merchant.create!(name: "Kohl Lamb")
@merchant_b = Merchant.create!(name: "Taryn Lamb")
@customer_a = Customer.create!(first_name: 'Sandeep', last_name: 'Patel')
@item_a = Item.create!(name: "Item A", description: "Item A", unit_price: 5, merchant: @merchant_a)
@item_b = Item.create!(name: "Item B", description: "Item B", unit_price: 10, merchant: @merchant_a)
@item_c = Item.create!(name: "Item C", description: "Item C", unit_price: 100, merchant: @merchant_a)
@item_d = Item.create!(name: "Vegan Bath Bombs", description: "Item D", unit_price: 10, merchant: @merchant_b)

@invoice_a = Invoice.create!(customer: @customer_a, status: :complete)
@ii_1 = InvoiceItem.create!(id: 10, invoice: @invoice_a, item: @item_a, quantity: 10, unit_price: 5, status: :shipped)
@ii_2 = InvoiceItem.create!(id: 11, invoice: @invoice_a, item: @item_b, quantity: 3, unit_price: 10, status: :shipped)
@ii_3 = InvoiceItem.create!(id: 12, invoice: @invoice_a, item: @item_c, quantity: 1, unit_price: 100, status: :shipped)
@ii_4 = InvoiceItem.create!(id: 13, invoice: @invoice_a, item: @item_d, quantity: 10, unit_price: 10, status: :pending)
@discount_a = BulkDiscount.create!(id: 20, merchant: @merchant_a, name: "Discount A", quantity_threshold: 3, percentage_discount: 0.1)
@discount_b = BulkDiscount.create!(id: 21, merchant: @merchant_a, name: "Discount B", quantity_threshold: 5, percentage_discount: 0.2)
@discount_b = BulkDiscount.create!(id: 22, merchant: @merchant_a, name: "Discount B", quantity_threshold: 100, percentage_discount: 0.5)

@transaction_a = Transaction.create!(credit_card_number: 13374206980085, result: :success, invoice: @invoice_a)