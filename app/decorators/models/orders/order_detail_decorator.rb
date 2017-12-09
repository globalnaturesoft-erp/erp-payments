Erp::Orders::OrderDetail.class_eval do

  # ======================== COMMISSION CACHE =====================================================
  after_save :update_cache_for_order_commission_amount

  # Save cache for commissions
  def update_cache_for_order_commission_amount
    order.update_cache_for_order_commission_amount
  end

end
