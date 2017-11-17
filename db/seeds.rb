Erp::Payments::PaymentType.destroy_all
Erp::Payments::PaymentType.create(name: 'Đơn bán hàng', code: Erp::Payments::PaymentType::CODE_SALES_ORDER, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Đơn đặt hàng', code: Erp::Payments::PaymentType::CODE_PURCHASE_ORDER, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Công nợ khách hàng', code: Erp::Payments::PaymentType::CODE_CUSTOMER, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Công nợ nhà cung cấp', code: Erp::Payments::PaymentType::CODE_SUPPLIER, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Hoa hồng', code: Erp::Payments::PaymentType::CODE_COMMISSION, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Chiết khấu', code: Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION, status: Erp::Payments::PaymentType::STATUS_ACTIVE)
Erp::Payments::PaymentType.create(name: 'Trả hàng', code: Erp::Payments::PaymentType::CODE_PRODUCT_RETURN, status: Erp::Payments::PaymentType::STATUS_ACTIVE)

Erp::Payments::PaymentType.create(name: 'Cố định: nhà + lương', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phát sinh: gởi hàng, văn phòng...', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phát sinh Marketing', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Công tác phí', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Tiếp khách', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Thưởng mở account – PKD (new acc)', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Phí vận chuyển hàng', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_payable: true)
Erp::Payments::PaymentType.create(name: 'Lãi ngân hàng', code: Erp::Payments::PaymentType::CODE_CUSTOM, status: Erp::Payments::PaymentType::STATUS_ACTIVE, is_receivable: true)
puts '==== Payment type created ===='

#pr_types = [Erp::Payments::PaymentRecord::PAYMENT_TYPE_RECEIVE, Erp::Payments::PaymentRecord::PAYMENT_TYPE_PAY]
#pr_status = [Erp::Payments::PaymentRecord::STATUS_PENDING, Erp::Payments::PaymentRecord::STATUS_DONE]
#
#Erp::Orders::Order.select {|o| o.remain_amount >= 50000 }.each do |order|
#  payment_date = order.order_date + 6.day
#  user = users.order("RANDOM()").first
#  payment = Erp::Payments::PaymentRecord.create(
#    code: 'PR'+id,
#    payment_type: order.sales? ? pr_types[0] : pr_types[1],
#    amount: (rand(50000/10000..(order.remain_amount/10000)).to_i*10000),
#    payment_date: rand(order.order_date..(payment_date <= Time.current ? payment_date : Time.current)),
#    status: pr_status[rand(pr_status.count)],
#    order_id: order.id,
#    accountant_id: user.id,
#    contact_id: order.sales? ? order.customer_id : order.supplier_id,
#    creator_id: user.id
#  )
#  puts '======================================'
#  put payment.errors.to_json
#end
