# USER
users = Erp::User.all

Erp::Payments::PaymentType.destroy_all
Erp::Payments::PaymentType.create(name: 'For Order', code: Erp::Payments::PaymentType::TYPE_FOR_ORDER)
Erp::Payments::PaymentType.create(name: 'For Contact', code: Erp::Payments::PaymentType::TYPE_FOR_CONTACT)
Erp::Payments::PaymentType.create(name: 'Commission', code: Erp::Payments::PaymentType::TYPE_COMMISSION)
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