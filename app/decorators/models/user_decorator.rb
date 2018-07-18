Erp::User.class_eval do

  def sales_total_amount(period={})
    query = Erp::Orders::Order.sales_orders.where(employee_id: self.id)
                              .where(status: Erp::Orders::Order::STATUS_CONFIRMED)
    if period.present?
      query = query.where('order_date >= ? AND order_date <= ?', period.from_date.beginning_of_day, period.to_date.end_of_day)
    end

    return query.sum(:cache_total)
  end

  def revenue_customer_by_period(period={})
    # all payment for customer
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)
      ])
    result = query.all_received(period: period.id).sum(:amount) - query.all_paid(period: period.id).sum(:amount)

    return result
  end

  def revenue_customer_commission_by_period(period={})
    # all customer permission amount
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION)
      ])
    result = query.all_received(period: period.id).sum(:amount) - query.all_paid(period: period.id).sum(:amount)

    return result
  end

  def revenue_sales_order_by_period(period={})
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER)
      ])

    result = query.all_received(period: period.id).sum(:amount) - query.all_paid(period: period.id).sum(:amount)
    return result
  end

  def revenue_by_period(period={})
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER),
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER),
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION),
      ])

    result = query.all_received(period: period.id).sum(:amount) - query.all_paid(period: period.id).sum(:amount)
    return result
  end

  def target_by_period(period)
    Erp::Targets::Target.where(period_id: period.id)
      .where(salesperson_id: self.id).last
  end

  def target_amount_by_period(period)
    target = self.target_by_period(period)
    return (target.present? ? target.amount : 0)
  end

  def target_commission_by_period(period={})
    revenue = self.revenue_by_period(period)

    target = target_by_period(period)
    if target.present?
      target.target_details.order('percent DESC').each do |td|
        if revenue >= (td.percent/100)*target_by_period(period).amount
          return td
        end
      end
    end

    return nil
  end
  
  # Get all sales order details, for_order orders
  def payment_for_order_sales_payment_records(params={})
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER)
      ])

    # from to date
    query = query.where("erp_payments_payment_records.payment_date >= ?", params[:from_date].to_date.beginning_of_day) if params[:from_date].present?
    query = query.where("erp_payments_payment_records.payment_date <= ?", params[:to_date].to_date.end_of_day) if params[:to_date].present?

    return query
  end

  def payment_for_order_sales_total(params={})
    self.payment_for_order_sales_payment_records(params).joins(:order).sum("erp_orders_orders.cache_total")
  end

  def payment_for_order_sales_paid_amount(params={})
    self.payment_for_order_sales_payment_records(params).sum(:amount)
  end

  def payment_for_order_sales_commission_amount(params={})
    self.payment_for_order_sales_payment_records(params).sum(:cache_for_order_commission_amount)
  end

  ############## need to review #############
  def payment_for_contact_sales_payment_records(params={})
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)
      ])

    # from to date
    query = query.where("erp_payments_payment_records.payment_date >= ?", params[:from_date].to_date.beginning_of_day) if params[:from_date].present?
    query = query.where("erp_payments_payment_records.payment_date <= ?", params[:to_date].to_date.end_of_day) if params[:to_date].present?

    return query
  end

  #def payment_for_contact_sales_total(params={})
  #  self.payment_for_order_sales_payment_records(params).joins(:order).sum("erp_orders_orders.cache_total")
  #end

  def payment_for_contact_sales_paid_amount(params={})
    self.payment_for_contact_sales_payment_records(params).sum(:amount)
  end

  def payment_for_contact_sales_commission_amount(params={})
    total = 0.0
    self.payment_for_contact_sales_payment_records(params).each do |pr|
      total += pr.for_contact_commission_amount(params).to_f
    end
    return total
  end
  ###################################

  def new_account_commission_amount(params={})
    total = 0.0
    self.payment_for_contact_sales_payment_records(params).each do |pr|
      total += pr.new_account_commission_amount
    end
    return total
  end

  # empployee target amount
  def employee_target_commission_amount(params={})
    total = 0.0
    # commission for employee target
    if params[:target_period].present?
      target = self.target_commission_by_period(params[:target_period])
      total += target.commission_amount if target.present?
    end

    return total
  end

  ## total commission by period
  #def commission_amount(params={})
  #  total = 0.0
  #  # commission for order
  #  total += self.payment_for_order_sales_commission_amount(params)
  #
  #  # commission for customer
  #  total += self.payment_for_contact_sales_commission_amount(params)
  #
  #  # commission for new account
  #  total += self.new_account_commission_amount(params)
  #
  #  # commission for employee target
  #  total += self.employee_target_commission_amount(params)
  #
  #  # commission for company target
  #  if params[:target_period].present?
  #    company_target = Erp::Targets::CompanyTarget.get_by_period(params[:target_period])
  #    total += company_target.commission_amount if company_target.present?
  #  end
  #
  #  return total
  #end
  
  ################### NEW VERSION - START ###################
  
  # get contacts of the staff
  def self.get_salesperson_contacts
    Erp::Contacts::Contact.where.not(salesperson_id: nil).where('erp_contacts_contacts.commission_percent != ?', 0.0)
  end
  
  # get contacts of an staff
  def get_salesperson_contacts
    Erp::Contacts::Contact.where(salesperson_id: self.id).where('erp_contacts_contacts.commission_percent != ?', 0.0)
  end
  
  #
  def commission_amount_by_customer(customer, options={})
    sales_paid = customer.sales_paid_by_period_amount(options)
    customer_commission = customer.customer_commission_total_amount(options)
    commission_percent = customer.commission_percent
    commission = ((sales_paid - customer_commission)/100)*commission_percent
    return commission
  end
  
  def commission_amount_by_customers(options={})
    total = 0.0
    self.get_salesperson_contacts.each do |c|
      total += self.commission_amount_by_customer(c, options)
    end
    return total
  end
  
  # total commission by period
  def commission_amount(options={})
    total = 0.0
    # commission for order
    total += self.payment_for_order_sales_commission_amount(options)

    # commission for customer
    total += self.commission_amount_by_customers(options)

    return total
  end
  
  # paid commission by period
  def commission_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.all_done.includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_COMMISSION})
      .where(employee_id: self.id)

    # from to date
    if params[:from_date].present?
      query = query.where("erp_payments_payment_records.payment_date >= ?", params[:from_date].to_date.beginning_of_day)
    end
    
    if params[:to_date].present?
      query = query.where("erp_payments_payment_records.payment_date <= ?", params[:to_date].to_date.end_of_day)
    end

    result = + query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)
  end

  # remain commission by period
  def commission_remain_amount(params={})
    return commission_amount(params) - commission_paid_amount(params)
  end
  
  # total target_commission by period // tien target NV và target doanh so cong ty
  def target_commission_amount(params={})
    total = 0.0

    # commission for employee target
    total += self.employee_target_commission_amount(params)

    # commission for company target
    if params[:target_period].present?
      company_target = Erp::Targets::CompanyTarget.get_by_period(params[:target_period])
      total += company_target.commission_amount if company_target.present?
    end

    return total
  end
  
  # paid target_commission by period
  def target_commission_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.all_done.includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_TARGET_COMMISSION})
      .where(employee_id: self.id)

    # from to date
    if params[:from_date].present?
      query = query.where("erp_payments_payment_records.payment_date >= ?", params[:from_date].to_date.beginning_of_day)
    end
    
    if params[:to_date].present?
      query = query.where("erp_payments_payment_records.payment_date <= ?", params[:to_date].to_date.end_of_day)
    end

    result = + query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)
  end

  # remain target_commission by period
  def target_commission_remain_amount(params={})
    return target_commission_amount(params) - target_commission_paid_amount(params)
  end
  
  ################### NEW VERSION - END   ###################

end
