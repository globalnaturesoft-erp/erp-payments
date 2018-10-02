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
      
      # payment record link helper
      def payment_record_link(payment_record, text=nil)
        text = text.nil? ? payment_record.code : text
        raw "<a href='#{erp_payments.backend_payment_record_path(payment_record)}' class='modal-link'>#{text}</a>"
      end
      
      # Payment account dropdown actions
      def account_dropdown_actions(account)
        actions = []
        
        actions << {
            text: '<i class="fa fa-edit"></i> '+t('edit'),
            href: erp_payments.edit_backend_account_path(account)
        } if can? :update, account
        
        actions << {
            text: '<i class="fa fa-eye-slash"></i> '+t('archive'),
            url: erp_payments.archive_backend_accounts_path(id: account),
            data_method: 'PUT',
            hide: account.archived,
            class: 'ajax-link'
        } if !Erp::Core.available?("ortho_k")
        
        actions << {
            text: '<i class="fa fa-eye"></i> '+t('unarchive'),
            url: erp_payments.unarchive_backend_accounts_path(id: account),
            data_method: 'PUT',
            hide: !account.archived,
            class: 'ajax-link'
        } if !Erp::Core.available?("ortho_k")
        
        actions << {
            text: '<i class="fa fa-check"></i> '+t('.set_active'),
            url: erp_payments.set_active_backend_accounts_path(id: account),
            data_method: 'PUT',
            class: 'ajax-link'
        } if can? :set_active, account
        
        actions << { divider: true } if (can? :delete, account)
        
        actions << {
            text: '<i class="fa fa-trash"></i> '+t('.set_deleted'),
            url: erp_payments.set_deleted_backend_accounts_path(id: account),
            data_method: 'PUT',
            class: 'ajax-link',
            data_confirm: t('.set_deleted_confirm')
        } if can? :set_deleted, account
        
        erp_datalist_row_actions(
          actions
        )
      end
      
      # Payment type dropdown actions
      def payment_type_dropdown_actions(payment_type)
        actions = []
        
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('edit'),
          href: erp_payments.edit_backend_payment_type_path(payment_type)
        } if can? :update, payment_type
        
        actions << {
          text: '<i class="fa fa-check"></i> '+t('.set_active'),
          url: erp_payments.set_active_backend_payment_types_path(id: payment_type),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.set_active_confirm')
        } if can? :set_active, payment_type
        
        actions << {
          text: '<i class="fa fa-close"></i> '+t('.set_deleted'),
          url: erp_payments.set_deleted_backend_payment_types_path(id: payment_type),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.set_deleted_confirm')
        } if can? :set_deleted, payment_type
        
        erp_datalist_row_actions(
          actions
        )
      end
    end
  end
end
