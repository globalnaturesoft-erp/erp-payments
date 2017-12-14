module Erp::Payments
  class PaymentTypeLimit < ApplicationRecord
    belongs_to :period, class_name: 'Erp::Periods::Period'
    belongs_to :payment_type, class_name: 'Erp::Payments::PaymentType'

    def amount=(new_price)
      self[:amount] = new_price.to_s.gsub(/\,/, '')
    end
    
    def period_name
      period.present? ? period.name : ''
    end
    
    def get_usage
      query = Erp::Payments::PaymentRecord.where(payment_type_id: self.payment_type_id)
        .where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
        .where('payment_date >= ?', period.from_date.beginning_of_day)
        .where('payment_date <= ?', period.to_date.end_of_day)
      return query.sum(:amount)
    end
  end
end