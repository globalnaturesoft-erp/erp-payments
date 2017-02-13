module Erp::Payments
  class PaymentRecord < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :accountant, class_name: "Erp::User", foreign_key: :accountant_id
    if Erp::Core.available?("contacts")
      belongs_to :contact, class_name: "Erp::Contacts::Contact"
      
      def contact_name
        contact.present? ? contact.contact_name : ''
      end
    end
    if Erp::Core.available?("sales")
      belongs_to :order, class_name: "Erp::Sales::Order"
    end
    
    after_save :order_update_cache_payment_status
    
    # class const
    PAYMENT_TYPE_RECEIVE = 'receive'
    PAYMENT_TYPE_PAY = 'pay'
    
    # get type method options
    def self.get_type_record_options()
      [
        {text: I18n.t('.receive'), value: Erp::Payments::PaymentRecord::PAYMENT_TYPE_RECEIVE},
        {text: I18n.t('.pay'), value: Erp::Payments::PaymentRecord::PAYMENT_TYPE_PAY}
      ]
    end
    
    def accountant_name
      accountant.present? ? accountant.name : ''
    end
    
    # DISPLAY ORDER INFORMATION
    # order date
    def order_date(params)
      if order.present?
        order.order_date
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).order_date
      end
    end
    
    # order expiration date
    def expiration_date(params)
      if order.present?
        order.expiration_date
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).expiration_date
      end
    end
    
    # order code
    def order_code(params)
      if order.present?
        order.code
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).code
      end
    end
    
    # order customer name
    def order_customer(params)
      if order.present?
        order.customer_name
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).customer_name
      end
    end
    
    # order paid amount
    def order_paid_amount(params)
      if order.present?
        order.paid_amount
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).paid_amount
      end
    end
    
    # order total
    def order_total(params)
      if order.present?
        order.total
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).total
      end
    end
    
    # order remain amount
    def order_remain_amount(params)
      if order.present?
        order.remain_amount
      elsif params[:order_id].present?
        Erp::Sales::Order.find(params[:order_id]).remain_amount
      end
    end
    
    def order_update_cache_payment_status
			if order.present?
				order.update_cache_payment_status
			end
		end
    
  end
end
