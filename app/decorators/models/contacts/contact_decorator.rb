Erp::Contacts::Contact.class_eval do

  # Get sales orders for contact (is ordered)
  def self.sales_orders
    query = Erp::Orders::Order.all_confirmed.sales_orders
      .where(customer_id: self.select(:id))
    return query
  end

  def sales_orders
    query = Erp::Contacts::Contact.sales_orders.where(customer_id: self.id)
    return query
  end

  # Get purchase orders for contact (is ordered)
  def self.purchase_orders
    query = Erp::Orders::Order.all_confirmed.purchase_orders
      .where(supplier_id: self.select(:id))
    return query
  end

  def purchase_orders
    query = Erp::Contacts::Contact.purchase_orders.where(supplier_id: self.id)
    return query
  end
  
  # Get sales product returns
  def self.sales_product_returns
    query = Erp::Qdeliveries::Delivery.all_delivered.sales_import_deliveries
      .where(customer_id: self.select(:id))
    return query
  end
  
  def sales_product_returns
    query = Erp::Contacts::Contact.sales_product_returns.where(customer_id: self.id)
    return query
  end
  
  # Get purchase product returns
  def self.purchase_product_returns
    query = Erp::Qdeliveries::Delivery.all_delivered.purchase_export_deliveries
      .where(supplier_id: self.select(:id))
    return query
  end
  
  def purchase_product_returns
    query = Erp::Contacts::Contact.purchase_product_returns.where(supplier_id: self.id)
    return query
  end

  # Tong ban hang
  def self.sales_order_total_amount(params={})
    query = self.sales_orders.payment_for_contact_orders(params)
      .where(customer_id: self.select(:id))

    total = query.sum(:cache_total)
    
    return total
  end
  
  # Tong hang ban bi tra lai
  def self.sales_return_total_amount(params={})
    query = self.sales_product_returns.get_deliveries_with_payment_for_contact(params)
    return query.sum(:cache_total)
  end

  # Tong ban hang sau khi da tru hang bi tra lai
  def self.sales_total_amount(params={})
    total = self.sales_order_total_amount(params)    
    total -= self.sales_return_total_amount(params)
    
    # init debt amount
    query = self.where.not(init_debt_date: nil).where(id: self.select(:id))
    if params[:from_date].present?
      query = query.where("init_debt_date >= ?", params[:from_date].to_date.beginning_of_day)
    end
    if params[:to_date].present?
      query = query.where("init_debt_date <= ?", params[:to_date].to_date.end_of_day)
    end    
    total += query.sum(:init_debt_amount)

    return total
  end
  
  # Tong tien hoa don ban hang
  def sales_order_total_amount(params={})
    query = self.sales_orders.payment_for_contact_orders(params)
    return query.sum(:cache_total)
  end
  
  # Tong tien hang ban bi tra lai
  def sales_return_total_amount(params={})
    query = self.sales_product_returns.get_deliveries_with_payment_for_contact(params)
    return query.sum(:cache_total)
  end

  # Tong doanh thu ban hang (sau khi da tru hang bi tra lai)
  def sales_total_amount(params={})
    total = self.sales_order_total_amount(params)
    
    total -= self.sales_return_total_amount(params)
    
    if self.init_debt_date.present? and
      (!params[:from_date].present? or params[:from_date].to_date.beginning_of_day <= self.init_debt_date) and
      (!params[:to_date].present? or params[:to_date].to_date.end_of_day >= self.init_debt_date)
        total += self.init_debt_amount
    end

    return total
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
      .where(customer_id: self.select(:id))

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
  
  
  #==============================================================
  #==============================================================
  #==============================================================
  #==============================================================
  

  
  # Tong tien nhap hang
  def self.purchase_order_total_amount(params={})
    query = self.purchase_orders.payment_for_contact_orders(params)
      .where(supplier_id: self.select(:id))

    total = query.sum(:cache_total)
    
    return total
  end
  
  # Tong hang nhap tra lai cho ncc
  def self.purchase_return_total_amount(params={})
    query = self.purchase_product_returns.get_deliveries_with_payment_for_contact(params)
    return query.sum(:cache_total)
  end

  # Purchase total amount for contact // đã trừ cho hàng trả lại
  def self.purchase_total_amount(params={})    
    total = self.purchase_order_total_amount(params)    
    total -= self.purchase_return_total_amount(params)
    
    # init debt amount
    query = self.where.not(init_debt_date: nil).where(id: self.select(:id))
    if params[:from_date].present?
      query = query.where("init_debt_date >= ?", params[:from_date].to_date.beginning_of_day)
    end
    if params[:to_date].present?
      query = query.where("init_debt_date <= ?", params[:to_date].to_date.end_of_day)
    end    
    total += query.sum(:init_debt_amount)

    return total
  end

  # Tong tien hoa don mua/nhap hang
  def purchase_order_total_amount(params={})
    query = self.purchase_orders.payment_for_contact_orders(params)
    return query.sum(:cache_total)
  end
  
  # Tong tien hang mua/nhap tra lai cho ncc
  def purchase_return_total_amount(params={})
    query = self.purchase_product_returns.get_deliveries_with_payment_for_contact(params)
    return query.sum(:cache_total)
  end

  # Tong tien mua/nhap hang (sau khi da tru hang tra lai cho ncc)
  def purchase_total_amount(params={})
    total = self.purchase_order_total_amount(params)
    
    total -= self.purchase_return_total_amount(params)
    
    if self.init_debt_date.present? and
      (!params[:from_date].present? or params[:from_date].to_date.beginning_of_day <= self.init_debt_date) and
      (!params[:to_date].present? or params[:to_date].to_date.end_of_day >= self.init_debt_date)
        total += self.init_debt_amount
    end

    return total
  end

  # Purchase paid amount for contact
  def self.purchase_paid_amount(params={})
    query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
      .includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
      .where(supplier_id: self.select(:id))

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
  
  # Sales paid amount by period //customers
  def self.sales_paid_by_period_amount(options={})
    #query = Erp::Payments::PaymentRecord.all_done
    #  .includes(:payment_type)
    #  .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER})
    #  .where(customer_id: self.select(:id))
    #
    #paid_total = - query.all_paid.sum(:amount) + query.all_received.sum(:amount)
    #
    #from_date = options[:from_date].present? ? options[:from_date].to_date.beginning_of_day : nil
    #to_date = options[:to_date].present? ? options[:to_date].to_date.end_of_day : (Time.now + 1.year)
    #from_amount = 0
    #to_amount = 0
    #
    #if from_date.present?
    #  sales_total = self.sales_total_amount(to_date: from_date)
    #  if paid_total >= sales_total
    #    from_amount = paid_total - sales_total
    #  elsif paid_total <= sales_total
    #    from_amount = 0
    #  end
    #end
    #
    #if to_date.present?
    #  sales_total = self.sales_total_amount(to_date: to_date)
    #  
    #  if sales_total >= 0 and paid_total >= 0
    #    if paid_total >= sales_total
    #      to_amount = sales_total
    #    else
    #      to_amount = paid_total
    #    end
    #  elsif sales_total <= 0 and  paid_total <= 0
    #    if paid_total >= sales_total
    #      to_amount = paid_total
    #    else
    #      to_amount = sales_total
    #    end
    #  else
    #    to_amount = 0
    #  end
    #end
    #
    #if from_date.present? and !to_date.present?
    #  return from_amount
    #elsif !from_date.present? and to_date.present?
    #  return to_amount
    #else from_date.present? and to_date.present?      
    #  from_amount = self.sales_paid_by_period_amount(to_date: (from_date - 1.day).end_of_day)      
    #  return to_amount - from_amount
    #end
    
    total = 0.0
    self.all.each do |c|
      total += c.sales_paid_by_period_amount(options)
    end
    
    return total
  end
  
  # Sales paid amount by period //customer
  def sales_paid_by_period_amount(options={})
    query = Erp::Payments::PaymentRecord.all_done
      .includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER})
      .where(customer_id: self.id)
      
    paid_total = - query.all_paid.sum(:amount) + query.all_received.sum(:amount)
    
    from_date = options[:from_date].present? ? options[:from_date].to_date.beginning_of_day : nil
    to_date = options[:to_date].present? ? options[:to_date].to_date.end_of_day : (Time.now + 1.year)
    from_amount = 0
    to_amount = 0
    
    if from_date.present?
      sales_total = self.sales_total_amount(to_date: from_date)
      if paid_total >= sales_total
        from_amount = paid_total - sales_total
      elsif paid_total <= sales_total
        from_amount = 0
      end
    end
    
    if to_date.present?
      sales_total = self.sales_total_amount(to_date: to_date)
      
      if sales_total >= 0 and paid_total >= 0
        if paid_total >= sales_total
          to_amount = sales_total
        else
          to_amount = paid_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month >= Time.now.month and to_date.year >= Time.now.year
          res = paid_total - sales_total
          if res > 0
            to_amount += res
          end
        end
        
        
      elsif sales_total <= 0 and  paid_total <= 0
        if paid_total >= sales_total
          to_amount = paid_total
        else
          to_amount = sales_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month >= Time.now.month and to_date.year >= Time.now.year
          res = - paid_total + sales_total
          if res > 0
            to_amount += res
          end
        end
        
      else
        to_amount = 0
      end
    end
    
    if from_date.present? and !to_date.present?
      return from_amount
    elsif !from_date.present? and to_date.present?
      return to_amount
    else from_date.present? and to_date.present?      
      from_amount = self.sales_paid_by_period_amount(to_date: (from_date - 1.day).end_of_day)      
      return to_amount - from_amount
    end
  end
  
  # Sales debt amount by period
  def self.sales_debt_by_period_amount(options={})
    self.sales_total_amount(options) - self.sales_paid_by_period_amount(options)
  end
  
  # Sales debt amount by period
  def sales_debt_by_period_amount(options={})
    self.sales_total_amount(options) - self.sales_paid_by_period_amount(options)
  end
  
  # Purchase paid amount by period //customers
  def self.purchase_paid_by_period_amount(options={})
    #query = Erp::Payments::PaymentRecord.all_done
    #  .includes(:payment_type)
    #  .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
    #  .where(supplier_id: self.select(:id))
    #
    #result = - query.all_paid_by_period(options).sum(:amount) + query.all_received_by_period(options).sum(:amount)
    #
    #return result
    
    total = 0.0
    self.all.each do |c|
      total += c.purchase_paid_by_period_amount(options)
    end
    
    return total
  end
  
  # Purchase paid amount by period //customer
  def purchase_paid_by_period_amount(options={})
    query = Erp::Payments::PaymentRecord.all_done
      .includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SUPPLIER})
      .where(supplier_id: self.id)

    paid_total = query.all_paid.sum(:amount) - query.all_received.sum(:amount)
    
    from_date = options[:from_date].present? ? options[:from_date].to_date.beginning_of_day : nil
    to_date = options[:to_date].present? ? options[:to_date].to_date.end_of_day : (Time.now + 1.year)
    from_amount = 0
    to_amount = 0
    
    if from_date.present?
      purchase_total = self.purchase_total_amount(to_date: from_date)
      if paid_total >= purchase_total
        from_amount = paid_total - purchase_total
      elsif paid_total <= purchase_total
        from_amount = 0
      end
    end
    
    if to_date.present?
      purchase_total = self.purchase_total_amount(to_date: to_date)
      
      if purchase_total >= 0 and paid_total >= 0
        if paid_total >= purchase_total
          to_amount = purchase_total
        else
          to_amount = paid_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month >= Time.now.month and to_date.year >= Time.now.year
          res = paid_total - purchase_total
          if res > 0
            to_amount += res
          end
        end
        
        
      elsif purchase_total <= 0 and  paid_total <= 0
        if paid_total >= purchase_total
          to_amount = paid_total
        else
          to_amount = purchase_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month >= Time.now.month and to_date.year >= Time.now.year
          res = - paid_total + purchase_total
          if res > 0
            to_amount += res
          end
        end
        
      else
        to_amount = 0
      end
    end
    
    if from_date.present? and !to_date.present?
      return from_amount
    elsif !from_date.present? and to_date.present?
      return to_amount
    else from_date.present? and to_date.present?      
      from_amount = self.purchase_paid_by_period_amount(to_date: (from_date - 1.day).end_of_day)      
      return to_amount - from_amount
    end
  end
  
  # Purchase debt amount by period
  def self.purchase_debt_by_period_amount(options={})
    self.purchase_total_amount(options) - self.purchase_paid_by_period_amount(options)
  end
  
  # Purchase debt amount by period
  def purchase_debt_by_period_amount(options={})
    self.purchase_total_amount(options) - self.purchase_paid_by_period_amount(options)
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
  
  # Customer commission paid amount
  def customer_commission_paid_by_period_amount(options={})
    query = Erp::Payments::PaymentRecord.all_done
      .includes(:payment_type)
      .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION})
      .where(customer_id: self.id)

    paid_total = query.all_paid.sum(:amount) - query.all_received.sum(:amount)
    
    from_date = options[:from_date].present? ? options[:from_date].to_date.beginning_of_day : nil
    to_date = options[:to_date].present? ? options[:to_date].to_date.end_of_day : (Time.now + 1.year)
    from_amount = 0
    to_amount = 0
    
    if from_date.present?
      customer_commission_total = self.customer_commission_total_amount(to_date: from_date)
      if paid_total >= customer_commission_total
        from_amount = paid_total - customer_commission_total
      elsif paid_total <= customer_commission_total
        from_amount = 0
      end
    end
    
    if to_date.present?
      customer_commission_total = self.customer_commission_total_amount(to_date: to_date)
      
      if customer_commission_total >= 0 and paid_total >= 0
        if paid_total >= customer_commission_total
          to_amount = customer_commission_total
        else
          to_amount = paid_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month == Time.now.month
          res = paid_total - customer_commission_total
          if res > 0
            to_amount += res
          end
        end
        
        
      elsif customer_commission_total <= 0 and  paid_total <= 0
        if paid_total >= customer_commission_total
          to_amount = paid_total
        else
          to_amount = customer_commission_total
        end
        
        # Truong hop thanh toan dư
        if to_date.month == Time.now.month
          res = - paid_total + customer_commission_total
          if res > 0
            to_amount += res
          end
        end
        
      else
        to_amount = 0
      end
    end
    
    if from_date.present? and !to_date.present?
      return from_amount
    elsif !from_date.present? and to_date.present?
      return to_amount
    else from_date.present? and to_date.present?      
      from_amount = self.customer_commission_paid_by_period_amount(to_date: (from_date - 1.day).end_of_day)      
      return to_amount - from_amount
    end
  end

  # Customer commission debt amount
  def customer_commission_debt_by_period_amount(options={})
    self.customer_commission_total_amount(options) - self.customer_commission_paid_by_period_amount(options)
  end
  
  
  # ====== CONG NO PHONG KHAM ====== Orders Tracking
  if Erp::Core.available?("ortho_k")
    # Tong ban hang
    def self.orders_tracking_sales_order_total_amount(params={})
      query = self.sales_orders.payment_for_order_orders(params)
        .where(customer_id: self.select(:id))
  
      return query.sum(:cache_total)
    end
    
    # Tong hang ban bi tra lai
    def self.orders_tracking_sales_return_total_amount(params={})
      query = self.sales_product_returns.get_deliveries_with_payment_for_order(params)
      return query.sum(:cache_total)
    end
  
    # Tong ban hang sau khi da tru hang bi tra lai
    def self.orders_tracking_sales_total_amount(params={})
      total = self.orders_tracking_sales_order_total_amount(params)
      
      total -= self.orders_tracking_sales_return_total_amount(params)
  
      return total
    end
    
    # Tong /Ban hang
    def orders_tracking_sales_order_total_amount(params={})
      query = self.sales_orders.payment_for_order_orders(params)
      return query.sum(:cache_total)
    end
    
    # Tong /Hang bi tra lai
    def orders_tracking_sales_return_total_amount(params={})
      query = self.sales_product_returns.get_deliveries_with_payment_for_order(params)
      return query.sum(:cache_total)
    end
  
    # Tong /Ban hang sau khi tru hang bi tra lai
    def orders_tracking_sales_total_amount(params={})
      total = self.orders_tracking_sales_order_total_amount(params)
      
      total -= self.orders_tracking_sales_return_total_amount(params)
  
      return total
    end
    
    # Sales paid amount for contact
    def self.orders_tracking_sales_paid_amount(params={})
      query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
        .includes(:payment_type)
        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SALES_ORDER})
        .where(customer_id: self.select(:id))
  
      result = - query.all_paid(params).sum(:amount) + query.all_received(params).sum(:amount)
  
      return result
    end
  
    def orders_tracking_sales_paid_amount(params={})
      query = Erp::Payments::PaymentRecord.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
        .includes(:payment_type)
        .where(erp_payments_payment_types: {code: Erp::Payments::PaymentType::CODE_SALES_ORDER})
        .where(customer_id: self.id)
  
      result = - query.all_paid(params).sum(:amount) + query.all_received(params).sum(:amount)
  
      return result
    end
  
    # Sales debt amount for contact
    def self.orders_tracking_sales_debt_amount(params={})
      self.orders_tracking_sales_total_amount(params) - self.orders_tracking_sales_paid_amount(params)
    end
  
    def orders_tracking_sales_debt_amount(params={})
      self.orders_tracking_sales_total_amount(params) - self.orders_tracking_sales_paid_amount(params)
    end
  end
end
