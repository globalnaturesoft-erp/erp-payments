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
    
  end
end
