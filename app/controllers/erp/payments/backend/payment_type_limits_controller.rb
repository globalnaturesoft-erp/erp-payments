module Erp
  module Payments
    module Backend
      class PaymentTypeLimitsController < Erp::Backend::BackendController
        def line_form
          @payment_type_limit = PaymentTypeLimit.new
    
          render partial: params[:partial], locals: {
            payment_type_limit: @payment_type_limit,
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
