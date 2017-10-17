Erp::Contacts::Contact.class_eval do
  # todo: check order/payment engine available?
  # Get sales orders for contact (is ordered)
  def sales_orders
    Erp::Orders::Order.sales_orders.where(customer_id: self.id)
                      .where(status: Erp::Orders::Order::STATUS_CONFIRMED)
  end
  
  def sales_orders_is_payment_for_contact
    sales_orders.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT)
  end
  
  # Sales total amount for contact
  def sales_total_amount(params={})
    query = self.sales_orders_is_payment_for_contact
    
    if params[:from].present?
      query = query.where('order_date >= ?', params[:from].beginning_of_day)
    end
    
    if params[:to].present?
      query = query.where('order_date <= ?', params[:to].end_of_day)
    end
    
    return query.sum(:cache_total)
  end
  
  # Sales paid amount for contact
  def sales_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER})
                                        .where(customer_id: self.id)
    if params[:from].present?
      query = query.where('payment_date >= ?', params[:from].beginning_of_day)
    end
    
    if params[:to].present?
      query = query.where('payment_date <= ?', params[:to].end_of_day)
    end
    
    return query.sum(:amount)
  end
  
  # Sales debt amount for contact
  def sales_debt_amount(params={})
    self.sales_total_amount(params) - self.sales_paid_amount(params)
  end
  
  # Get purchase orders for contact (is ordered)
  def purchase_orders
    Erp::Orders::Order.purchase_orders.where(supplier_id: self.id)
                      .where(status: Erp::Orders::Order::STATUS_CONFIRMED)
  end
  
  def purchase_orders_is_payment_for_contact
    purchase_orders.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT)
  end
  
  # Purchase total amount for contact
  def purchase_total_amount(params={})
    query = self.purchase_orders_is_payment_for_contact
    
    if params[:from].present?
      query = query.where('order_date >= ?', params[:from].beginning_of_day)
    end
    
    if params[:to].present?
      query = query.where('order_date <= ?', params[:to].end_of_day)
    end
    
    return query.sum(:cache_total)
  end
  
  # Purchase paid amount for contact
  def purchase_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
                                        .includes(:payment_type)
                                        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
                                        .where(supplier_id: self.id)
    if params[:from].present?
      query = query.where('payment_date >= ?', params[:from].beginning_of_day)
    end
    
    if params[:to].present?
      query = query.where('payment_date <= ?', params[:to].end_of_day)
    end
    
    return query.sum(:amount)
  end
  
  # Sales debt amount for contact
  def purchase_debt_amount(params={})
    self.purchase_total_amount(params) - self.purchase_paid_amount(params)
  end
end