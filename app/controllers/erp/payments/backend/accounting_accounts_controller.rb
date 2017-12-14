module Erp
  module Payments
    module Backend
      class AccountingAccountsController < Erp::Backend::BackendController
        before_action :set_accounting_account, only: [:set_active, :set_deleted, :show, :edit, :update]
    
        # GET /accounting_accounts
        def list
          @accounting_accounts = AccountingAccount.all
        end
    
        # GET /accounting_accounts/1
        def show
        end
    
        # GET /accounting_accounts/new
        def new
          @accounting_account = AccountingAccount.new
        end
    
        # GET /accounting_accounts/1/edit
        def edit
        end
    
        # POST /accounting_accounts
        def create
          @accounting_account = AccountingAccount.new(accounting_account_params)
          @accounting_account.creator = current_user
          @accounting_account.set_active
    
          if @accounting_account.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @accounting_account.name,
                value: @accounting_account.id
              }
            else
              redirect_to erp_payments.edit_backend_accounting_account_path(@accounting_account), notice: t('.success')
            end
          else
            render :new
          end          
        end
    
        # PATCH/PUT /accounting_accounts/1
        def update
          if @accounting_account.update(accounting_account_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @accounting_account.name,
                value: @accounting_account.id
              }
            else
              redirect_to erp_payments.edit_backend_accounting_account_path(@accounting_account), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # Set active /accounts/active?id=1
        def set_active
          @accounting_account.set_active
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_accounting_accounts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Set deleted /accounts/deleted?id=1
        def set_deleted
          @accounting_account.set_deleted
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_accounting_accounts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        def dataselect
          respond_to do |format|
            format.json {
              render json: AccountingAccount.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_accounting_account
            @accounting_account = AccountingAccount.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def accounting_account_params
            params.fetch(:accounting_account, {}).permit(:code, :name)
          end
      end
    end
  end
end
