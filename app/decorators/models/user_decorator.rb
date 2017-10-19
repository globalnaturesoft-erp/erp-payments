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
                                .where(payment_type_id: [Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER),
                                                         Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)])
    result = query.all_received(period).sum(:amount) - query.all_paid(period).sum(:amount)
    return result
  end
  
  def target_by_period(period)
    Erp::Targets::Target.where(period_id: period.id)
                        .where(salesperson_id: self.id).last
  end
  
  def target_commission_by_period(period={})
    revenue = self.revenue_by_period(period)
    target_by_period(period).target_details.order('percent DESC').each do |td|
      if revenue >= (td.percent/100)*target_by_period(period).amount
        return td
      end
    end
    return target_by_period(period).target_details.new
  end
  
end