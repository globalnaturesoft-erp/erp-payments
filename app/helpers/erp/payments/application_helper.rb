module Erp
  module Payments
    module ApplicationHelper
      # display type for payment record
      def display_payment_record_type(payment_record)
        str = []
        str << payment_record.pay_receive
        str << payment_record.payment_type_code
        return str.join("_")
      end
      
      # order link helper
      def payment_record_link(payment_record, text=nil)
        text = text.nil? ? payment_record.code : text
        raw "<a href='#{erp_payments.backend_payment_record_path(payment_record)}' class='modal-link'>#{text}</a>"
      end
      
    end
  end
end
