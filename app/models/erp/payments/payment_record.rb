module Erp::Payments
  class PaymentRecord < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :accountant, class_name: "Erp::User", foreign_key: :accountant_id
    if Erp::Core.available?("contacts")
      belongs_to :contact, class_name: "Erp::Contacts::Contact"
      
      def contact_name
        contact.present? ? contact.contact_name : ''
      end
      
      def contact_address
        contact.present? ? contact.address : ''
      end
      
      def contact_phone
        contact.present? ? contact.phone : ''
      end
    end
    
    def creator_name
      creator.name
    end
    
    if Erp::Core.available?("orders")
      belongs_to :order, class_name: "Erp::Orders::Order"
    end
    
    validates :payment_date, :contact_id, :accountant_id, :presence => true
    
    after_save :order_update_cache_payment_status
    after_destroy :order_update_cache_payment_status
    
    # class const
    PAYMENT_TYPE_RECEIVE = 'receive'
    PAYMENT_TYPE_PAY = 'pay'
    
    STATUS_PENDING = 'pending'
    STATUS_DONE = 'done'
    
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
        Erp::Orders::Order.find(params[:order_id]).order_date
      end
    end
    
    # order expiration date
    def payment_deadline(params)
      if order.present?
        order.get_payment_deadline
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).get_payment_deadline
      end
    end
    
    # order code
    def order_code(params)
      if order.present?
        order.code
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).code
      end
    end
    
    # order customer name
    def order_customer(params)
      if order.present?
        order.customer_name
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).customer_name
      end
    end
    
    # order paid amount
    def order_paid_amount(params)
      if order.present?
        order.paid_amount
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).paid_amount
      end
    end
    
    # order total
    def order_total(params)
      if order.present?
        order.total
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).total
      end
    end
    
    # order remain amount
    def order_remain_amount(params)
      if order.present?
        order.remain_amount
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).remain_amount
      end
    end
    
    def order_update_cache_payment_status
			if order.present?
				order.update_cache_payment_status
			end
		end
    
    def confirm
      update_attributes(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end
    
    def self.confirm_all
      update_all(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end
    
    def done?
      self.status == Erp::Payments::PaymentRecord::STATUS_DONE ? true : false
    end
    
    def pending?
      self.status == Erp::Payments::PaymentRecord::STATUS_PENDING ? true : false
    end
    
    def self.get_order_payment_records(params)
      self.where(order_id: params[:order_id])
    end
    
    # Get all done payment_records
    def self.all_done
      self.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end
    
    # Get receive payment record
    def self.all_received
      self.where(payment_type: Erp::Payments::PaymentRecord::PAYMENT_TYPE_RECEIVE)
    end
    
    # Get pay payment record
    def self.all_paid
      self.where(payment_type: Erp::Payments::PaymentRecord::PAYMENT_TYPE_PAY)
    end
  end
end
