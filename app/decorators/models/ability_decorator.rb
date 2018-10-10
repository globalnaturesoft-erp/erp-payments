Erp::Ability.class_eval do
  def payments_ability(user)
    can :read, Erp::Payments::PaymentRecord
    
    # Change payment type: thay doi loai cua phieu thu/chi tuy chinh
    can :change_payment_type, Erp::Payments::PaymentRecord do |payment_record|
      if Erp::Core.available?("ortho_k")
        !payment_record.is_deleted? and
        (payment_record.payment_type_code == Erp::Payments::PaymentType::CODE_CUSTOM) and
        user.get_permission(:accounting, :payments, :payment_records, :change_payment_type) == 'yes'
      else
        !payment_record.is_deleted? and
        (payment_record.payment_type_code == Erp::Payments::PaymentType::CODE_CUSTOM)
      end
    end
    
    # Payment record
    can :print, Erp::Payments::PaymentRecord do |payment_record|
      payment_record.is_done?
    end
    
    can :create, Erp::Payments::PaymentRecord do |payment_record|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:accounting, :payments, :payment_records, :create) == 'yes'
      else
        true
      end
    end
    
    can :update, Erp::Payments::PaymentRecord do |payment_record|
      if Erp::Core.available?("ortho_k")
        !payment_record.is_deleted? and
        (
          user.get_permission(:accounting, :payments, :payment_records, :update) == 'yes' or
          (
            user.get_permission(:accounting, :payments, :payment_records, :update) == 'in_day' and
            (payment_record.confirmed_at.nil? or (Time.now < payment_record.confirmed_at.end_of_day and payment_record.is_done?))
          )
        )
      else
        !payment_record.is_deleted?
      end
    end
    
    can :set_done, Erp::Payments::PaymentRecord do |payment_record|
      !payment_record.is_deleted? and !payment_record.is_done?
    end
    
    can :set_deleted, Erp::Payments::PaymentRecord do |payment_record|
      if Erp::Core.available?("ortho_k")
        !payment_record.is_deleted? and user.get_permission(:accounting, :payments, :payment_records, :delete) == 'yes'
      else
        !payment_record.is_deleted?
      end
    end
    
    # Account
    can :create, Erp::Payments::Account do |account|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:accounting, :payments, :accounts, :create) == 'yes'
      else
        true
      end
    end
    
    can :update, Erp::Payments::Account do |account|
      if Erp::Core.available?("ortho_k")
        !account.is_deleted? and user.get_permission(:accounting, :payments, :accounts, :update) == 'yes'
      else
        !account.is_deleted?
      end
    end
    
    can :set_active, Erp::Payments::Account do |account|
      false
    end
    
    can :set_deleted, Erp::Payments::Account do |account|
      if Erp::Core.available?("ortho_k")
        !account.is_deleted? and user.get_permission(:accounting, :payments, :accounts, :delete) == 'yes'
      else
        !account.is_deleted?
      end
    end
    
    # Payment type
    can :create, Erp::Payments::PaymentType do |payment_type|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:accounting, :payments, :payment_types, :create) == 'yes'
      else
        true
      end
    end
    
    can :update, Erp::Payments::PaymentType do |payment_type|
      if Erp::Core.available?("ortho_k")
        !payment_type.is_deleted? and user.get_permission(:accounting, :payments, :payment_types, :update) == 'yes'
      else
        !payment_type.is_deleted?
      end
    end
    
    can :set_active, Erp::Payments::PaymentType do |payment_type|
      false
    end
    
    can :set_deleted, Erp::Payments::PaymentType do |payment_type|
      if Erp::Core.available?("ortho_k")
        !payment_type.is_deleted? and user.get_permission(:accounting, :payments, :payment_types, :delete) == 'yes'
      else
        !payment_type.is_deleted?
      end
    end
  end
end
