Erp::Payments::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "backend/payments" do
			resources :payment_terms do
				collection do
					post 'list'
					get 'dataselect'
					delete 'delete_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
				end
			end
			resources :payment_methods do
				collection do
					post 'list'
					get 'dataselect'
					delete 'delete_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
				end
			end
			resources :payment_records do
				collection do
					post 'list'
					put 'set_done'
					put 'set_deleted'
					put 'set_done_all'
					put 'set_deleted_all'
					post 'order_payment_record_list'
					get 'liabilities_tracking'
					post 'liabilities_tracking_table'
					get 'liabilities_tracking_table_details'
					get 'supplier_liabilities_tracking'
					post 'supplier_liabilities_tracking_table'
					get 'supplier_liabilities_tracking_table_details'
					get 'commission'
					post 'commission_table'
					get 'commission_details'
					get 'customer_commission'
					post 'customer_commission_table'
					get 'customer_commission_details'
					get 'ajax_info_form_for_order'
					get 'ajax_info_form_for_customer'
					get 'ajax_info_form_for_supplier'
					get 'ajax_info_form_for_commission'
					get 'ajax_info_form_for_customer_commission'
					get 'ajax_info_form_for_delivery'
					get 'ajax_employee_field'
					get 'ajax_amount_field'
					get 'ajax_address_field'
					get 'show_modal'
					post 'show_list'
					get 'pdf'
					get 'xlsx'
					get 'pay_xlsx'
					get 'receive_xlsx'

					get 'xlsx_export_liabilities'
				end
			end
			resources :debts do
				collection do
					post 'list'
					get 'dataselect'
					delete 'delete_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
					post 'order_debt_list'
				end
			end
			resources :accounts do
				collection do
					post 'list'
					get 'dataselect'
					delete 'delete_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
					put 'set_active'
					put 'set_deleted'
				end
			end
			resources :payment_types do
				collection do
					post 'list'
					get 'dataselect'
					put 'set_active'
					put 'set_deleted'
				end
			end
			resources :accounting_accounts do
				collection do
          get 'dataselect'
        end
      end
		end
	end
end
