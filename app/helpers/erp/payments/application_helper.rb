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
      
    end
  end
end
