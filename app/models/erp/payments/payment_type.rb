module Erp::Payments
  class PaymentType < ApplicationRecord
    
    has_many :payment_type_limits, inverse_of: :payment_type, dependent: :destroy
    accepts_nested_attributes_for :payment_type_limits, :reject_if => lambda { |a| a[:period_id].blank? or a[:amount].blank? }, :allow_destroy => true
    
    # class const
    CODE_SALES_ORDER = 'sales_order'
    CODE_PURCHASE_ORDER = 'purchase_order'
    CODE_CUSTOMER = 'customer'
    CODE_SUPPLIER = 'supplier'
    CODE_PRODUCT_RETURN = 'product_return'
    #CODE_SUPPLIER_PRODUCT_RETURN = 'supplier_product_return' Cập nhật thêm phần này
    CODE_COMMISSION = 'commission'
    CODE_CUSTOMER_COMMISSION = 'customer_commission'
    # hoat dong tai chinh, quan ly doanh nghiep
    CODE_FINANCIAL_EXPENSES = 'financial_expenses'
    CODE_ADMINISTRATIVE_EXPENSES = 'administrative_expenses'
    CODE_CUSTOM = 'custom'
    
    STATUS_ACTIVE = 'active'
    STATUS_DELETED = 'deleted'
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []
      show_archived = false
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end
      
      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      return query
    end
    
    def self.search(params)
      query = self.where(code: Erp::Payments::PaymentType::CODE_CUSTOM)
      query = self.filter(query, params)
      
      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?
        
        query = query.order(order)
      end
      
      return query
    end
    
    # data for dataselect ajax
    def self.dataselect(keyword='', params='')
      query = self.all_active
      
      if params[:payment_type_code].present?
        query = query.where(code: params[:payment_type_code])
      end
      
      if params[:is_payable].present? and params[:is_payable] == 'true'
        query = query.where(is_payable: true)
      end
      
      if params[:is_receivable].present? and params[:is_receivable] == 'true'
        query = query.where(is_receivable: true)
      end
      
      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end
      
      query = query.limit(20).map{|ptype| {value: ptype.id, text: ptype.name} }
    end
    
    def set_code_is_custom
      self.update_columns(code: Erp::Payments::PaymentType::CODE_CUSTOM)
    end
    
    def self.all_active
      query = self.where(status: Erp::Payments::PaymentType::STATUS_ACTIVE)
      return query
    end
    
    def self.get_custom_payment_types
      query = self.all_active.where(code: Erp::Payments::PaymentType::CODE_CUSTOM)
      return query
    end
    
    def self.payables
      self.where(is_payable: true)
    end
    
    def self.receivables
      self.where(is_receivable: true)
    end
    
    # SET status
    def set_active
      update_columns(status: Erp::Payments::PaymentType::STATUS_ACTIVE)
    end
    
    def set_deleted
      update_columns(status: Erp::Payments::PaymentType::STATUS_DELETED)
    end
    
    # Check if deleted/active?
    def is_active?
      return self.status == Erp::Payments::PaymentType::STATUS_ACTIVE
    end
    
    def is_deleted?
      return self.status == Erp::Payments::PaymentType::STATUS_DELETED
    end
    
    # Get payment type limits
    def get_limits(params={})
      periods = Erp::Periods::Period.where(status: Erp::Periods::Period::STATUS_ACTIVE)
      if params[:date].present?
        periods = periods.where('from_date <= ? AND to_date >= ?', params[:date].to_date.end_of_day, params[:date].to_date.beginning_of_day)
      end
      return [] if periods.empty?
      return Erp::Payments::PaymentTypeLimit.where(payment_type_id: self.id)
            .where(period_id: periods.map{|p| p.id})
      
    end
    
    # Payment record amount by payment type
    def receive_amount_by_payment_type(params={})
      Erp::Payments::PaymentRecord.all_done.all_received(params).where(payment_type_id: self.id).sum(:amount)
    end
    
    def paid_amount_by_payment_type(params={})
      Erp::Payments::PaymentRecord.all_done.all_paid(params).where(payment_type_id: self.id).sum(:amount)
    end
    
    def self.receive_amount_by_payment_type(params={})
      Erp::Payments::PaymentRecord.all_done.all_received(params).where(payment_type_id: self.ids).sum(:amount)
    end
    
    def self.paid_amount_by_payment_type(params={})
      Erp::Payments::PaymentRecord.all_done.all_paid(params).where(payment_type_id: self.ids).sum(:amount)
    end
    
    def self.remain_amount_by_payment_type(params={})
      self.receive_amount_by_payment_type(params) - self.paid_amount_by_payment_type(params)
    end
  end
end
