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
					put 'confirm'
					put 'confirm_all'
					delete 'delete_all'
					post 'order_payment_record_list'
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
		end
	end
end