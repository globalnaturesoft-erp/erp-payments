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
      
      # Payment record dropdown actions
      def payment_record_dropdown_actions(payment_record)
        actions = []
        
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          url: erp_payments.backend_payment_record_path(payment_record),
          class: 'modal-link'
        } if can? :print, payment_record
        
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          url: erp_payments.edit_backend_payment_record_path(payment_record),
          class: 'modal-link has-form'
        } if can? :update, payment_record
        
        actions << {
          text: '<i class="fa fa-check"></i> '+t('confirm'),
          url: erp_payments.set_done_backend_payment_records_path(id: payment_record),
          data_method: 'PUT',
          hide: payment_record.is_done?,
          class: 'ajax-link',
          data_confirm: t('.confirm_confirm')
        } if can? :set_done, payment_record
        
        actions << {
          text: '<i class="fa fa-exchange"></i> Chuyển phiếu',
          url: erp_payments.change_payment_type_backend_payment_records_path(id: payment_record)
        } if can? :change_payment_type, payment_record
        
        if can? :set_deleted, payment_record
          if (can? :print, payment_record) or (can? :update, payment_record) or (can? :set_done, payment_record) or (can? :change_payment_type, payment_record)
            actions << { divider: true }
          end
        end
        
        actions << {
          text: '<i class="fa fa-trash"></i> '+t('.delete'),
          url: erp_payments.set_deleted_backend_payment_records_path(id: payment_record),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delete_confirm')
        } if can? :set_deleted, payment_record
        
        erp_datalist_row_actions(
          actions
        )
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
        
        if can? :set_deleted, account
          if (can? :update, account) or (can? :set_active, account)
            actions << { divider: true }
          end
        end
        
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
        
        if can? :set_deleted, payment_type
          if (can? :update, payment_type) or (can? :set_active, payment_type)
            actions << { divider: true }
          end
        end
        
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
