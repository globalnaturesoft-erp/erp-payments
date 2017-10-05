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
					get 'commission'
					post 'commission_table'
					get 'commission_details'
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
				end
			end
			resources :payment_types do
				collection do
					post 'list'
					get 'dataselect'
				end
			end
		end
	end
end