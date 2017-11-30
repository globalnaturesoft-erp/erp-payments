Erp::Contacts::Contact.class_eval do

  # Get sales orders for contact (is ordered)
  def self.sales_orders
    query = Erp::Orders::Order.sales_orders.where(status: Erp::Orders::Order::STATUS_CONFIRMED)
      .where(customer_id: self.ids)
    return query
  end

  def sales_orders
    query = Erp::Contacts::Contact.sales_orders.where(customer_id: self.id)
    return query
  end

  # Get purchase orders for contact (is ordered)
  def self.purchase_orders
    query = Erp::Orders::Order.purchase_orders.where(status: Erp::Orders::Order::STATUS_CONFIRMED)
      .where(supplier_id: self.ids)
    return query
  end

  def purchase_orders
    query = Erp::Contacts::Contact.purchase_orders.where(supplier_id: self.id)
    return query
  end

  # Sales total amount for contact
  def self.sales_total_amount(params={})
    query = self.sales_orders.payment_for_contact_orders(params)
      .where(customer_id: self.ids)

    return query.sum(:cache_total)
  end

  def sales_total_amount(params={})
    query = self.sales_orders.payment_for_contact_orders(params)

    return query.sum(:cache_total)
  end

  # Sales total amount for contact without commission
  def sales_total_without_commission_amount(params={})
    return self.sales_total_amount(params) - self.customer_commission_total_amount(params)
  end

  # Sales paid amount for contact
  def self.sales_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER})
                                        .where(customer_id: self.ids)

    result = - query.all_paid(params).sum(:amount) + query.all_received(params).sum(:amount)

    return result
  end

  def sales_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER})
                                        .where(customer_id: self.id)

    result = - query.all_paid(params).sum(:amount) + query.all_received(params).sum(:amount)

    return result
  end

  # Sales debt amount for contact
  def self.sales_debt_amount(params={})
    self.sales_total_amount(params) - self.sales_paid_amount(params)
  end

  def sales_debt_amount(params={})
    self.sales_total_amount(params) - self.sales_paid_amount(params)
  end

  # Purchase total amount for contact
  def self.purchase_total_amount(params={})
    query = self.purchase_orders.payment_for_contact_orders(params)

    return query.sum(:cache_total)
  end

  def purchase_total_amount(params={})
    query = self.purchase_orders.payment_for_contact_orders(params)

    return query.sum(:cache_total)
  end

  # Purchase paid amount for contact
  def self.purchase_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
                                        .where(supplier_id: self.ids)

    result = query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)

    return result
  end

  def purchase_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
                                        .where(supplier_id: self.id)

    result = query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)

    return result
  end

  # Purchase debt amount for contact
  def self.purchase_debt_amount(params={})
    self.purchase_total_amount(params) - self.purchase_paid_amount(params)
  end

  def purchase_debt_amount(params={})
    self.purchase_total_amount(params) - self.purchase_paid_amount(params)
  end

  # Customer commission total amount
  def customer_commission_total_amount(params={})
    query = self.sales_orders.payment_for_contact_orders(params)

    return query.sum(:cache_customer_commission_amount)
  end

  # Customer commission paid amount
  def customer_commission_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION})
                                        .where(customer_id: self.id)

    result = query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)

    return result
  end

  # Customer commission debt amount
  def customer_commission_debt_amount(params={})
    self.customer_commission_total_amount(params) - self.customer_commission_paid_amount(params)
  end
end
