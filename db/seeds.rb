# USER
users = Erp::User.all

Erp::Payments::PaymentType.destroy_all
Erp::Payments::PaymentType.create(name: 'Đơn hàng', code: Erp::Payments::PaymentType::TYPE_FOR_ORDER)
Erp::Payments::PaymentType.create(name: 'Khách hàng/NCC', code: Erp::Payments::PaymentType::TYPE_FOR_CONTACT)
Erp::Payments::PaymentType.create(name: 'Chiết khấu/Hoa hồng', code: Erp::Payments::PaymentType::TYPE_COMMISSION)

Erp::Payments::PaymentType.create(name: 'Văn phòng phẩm', code: Erp::Payments::PaymentType::TYPE_CUSTOM)
Erp::Payments::PaymentType.create(name: 'Công tác phí', code: Erp::Payments::PaymentType::TYPE_CUSTOM)
Erp::Payments::PaymentType.create(name: 'Phí tàu xe, vé máy bay', code: Erp::Payments::PaymentType::TYPE_CUSTOM)
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