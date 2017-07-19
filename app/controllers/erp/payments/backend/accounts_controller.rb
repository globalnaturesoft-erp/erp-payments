module Erp
  module Payments
    module Backend
      class AccountsController < Erp::Backend::BackendController
        before_action :set_account, only: [:archive, :unarchive, :edit, :update, :destroy]
        before_action :set_accounts, only: [:archive_all, :unarchive_all, :delete_all]
    
        # POST /debts/list
        def list
          @accounts = Account.search(params).paginate(:page => params[:page], :per_page => 5)
          
          render layout: nil
        end
    
        # GET /accounts/new
        def new
          @account = Account.new
        end
    
        # GET /accounts/1/edit
        def edit
        end
    
        # POST /accounts
        def create
          @account = Account.new(account_params)
          @account.creator = current_user
    
          if @account.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @account.name,
                value: @account.id
              }
            else
              redirect_to erp_payments.edit_backend_account_path(@account), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /accounts/1
        def update
          if @account.update(account_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @account.name,
                value: @account.id
              }              
            else
              redirect_to erp_payments.edit_backend_account_path(@account), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /accounts/1
        def destroy
          @account.destroy
          
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_accounts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # Archive /accounts/archive?id=1
        def archive
          @account.archive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_accounts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # Unarchive /accounts/unarchive?id=1
        def unarchive
          @account.unarchive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_accounts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE /accounts/delete_all?ids=1,2,3
        def delete_all         
          @accounts.destroy_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Archive /accounts/archive_all?ids=1,2,3
        def archive_all         
          @accounts.archive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Unarchive /accounts/unarchive_all?ids=1,2,3
        def unarchive_all
          @accounts.unarchive_all
          
          respond_to do |format|
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
              render json: Account.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_account
            @account = Account.find(params[:id])
          end
          
          def set_accounts
            @accounts = Account.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def account_params
            params.fetch(:account, {}).permit(:name, :account_number, :owner)
          end
      end
    end
  end
end
