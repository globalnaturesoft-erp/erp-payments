Erp::Orders::Order.class_eval do

  # ======================== COMMISSION CACHE =====================================================
  after_save :update_cache_for_order_commission_amount

  # Save cache for commissions
  def update_cache_for_order_commission_amount
    done_receiced_payment_records.each do |pr|
      pr.update_cache_for_order_commission_amount
    end
  end

end
