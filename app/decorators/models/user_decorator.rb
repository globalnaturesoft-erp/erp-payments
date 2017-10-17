Erp::User.class_eval do
  
  def revenue_by_period(period={})
    Erp::Payments::PaymentRecord.all_done.all_received
                                .where(employee_id: self.id)
                                .sum(:amount)
  end
  
  def target_commission_by_period(period={})
  end
end