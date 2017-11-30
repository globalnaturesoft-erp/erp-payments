Erp::User.class_eval do

  def sales_total_amount(period={})
    query = Erp::Orders::Order.sales_orders.where(employee_id: self.id)
                              .where(status: Erp::Orders::Order::STATUS_CONFIRMED)
    if period.present?
      query = query.where('order_date >= ? AND order_date <= ?', period.from_date.beginning_of_day, period.to_date.end_of_day)
    end

    return query.sum(:cache_total)
  end

  def revenue_by_period(period={})
    query = Erp::Payments::PaymentRecord.all_done.where(employee_id: self.id)
      .where(payment_type_id: [
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER),
        Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)
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

    return Erp::Targets::TargetDetail.new
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
    self.payment_for_order_sales_payment_records(params).joins(:order).sum("erp_orders_orders.cache_commission_amount")
  end

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
      total += pr.commission_amount.to_f
    end
    return total
  end

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

  # total commission by period
  def commission_amount(params={})
    total = 0.0
    # commission for order
    total += self.payment_for_order_sales_commission_amount(params)

    # commission for customer
    total += self.payment_for_contact_sales_commission_amount(params)

    # commission for new account
    total += self.new_account_commission_amount(params)

    # commission for employee target
    total += self.employee_target_commission_amount(params)

    # commission for company target
    if params[:target_period].present?
      company_target = Erp::Targets::CompanyTarget.get_by_period(params[:target_period])
      total += company_target.commission_amount if company_target.present?
    end

    return total
  end

  # paid commission by period
  def commission_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
      .includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_COMMISSION})
      .where(employee_id: self.id)

    # from to date
    query = query.where("erp_payments_payment_records.payment_date >= ?", params[:from_date].to_date.beginning_of_day) if params[:from_date].present?
    query = query.where("erp_payments_payment_records.payment_date <= ?", params[:to_date].to_date.end_of_day) if params[:to_date].present?

    result = + query.all_paid(params).sum(:amount) - query.all_received(params).sum(:amount)
  end

  # remain commission by period
  def commission_remain_amount(params={})
    return commission_amount(params) - commission_paid_amount(params)
  end

end
