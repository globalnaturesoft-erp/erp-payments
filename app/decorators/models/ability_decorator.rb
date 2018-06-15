Erp::Ability.class_eval do
  def payments_ability(user)
    can :read, Erp::Payments::PaymentRecord
    
    can :change_payment_type, Erp::Payments::PaymentRecord do |payment_record|
      payment_record.payment_type_code == Erp::Payments::PaymentType::CODE_CUSTOM
    end
  end
end
