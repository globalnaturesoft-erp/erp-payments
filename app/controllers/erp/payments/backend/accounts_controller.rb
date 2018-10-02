module Erp
  module Payments
    module Backend
      class AccountsController < Erp::Backend::BackendController
        before_action :set_account, only: [:account_details, :payment_records_by_account, :set_active, :set_deleted, :archive, :unarchive, :edit, :update, :destroy]
        before_action :set_accounts, only: [:archive_all, :unarchive_all, :delete_all]

        def index
          authorize! :accounting_payments_accounts_index, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day
        end
        
        # POST /debts/list
        def list
          authorize! :accounting_payments_accounts_index, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          @period_name = nil
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
            @period_name = @period.name
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          @accounts = Account.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end
        
        def account_details
        end
        
        def payment_records_by_account
          authorize! :accounting_payments_accounts_payment_records_by_account, nil
          
          @from_date = params[:from_date].to_date
          @to_date = params[:to_date].to_date
          
          @payment_records = @account.payment_records(from_date: @from_date, to_date: @to_date)
          
          @payment_records = @payment_records.order('erp_payments_payment_records.payment_date DESC')
            .paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end

        # GET /accounts/new
        def new
          @account = Account.new
          
          authorize! :create, @account
        end

        # GET /accounts/1/edit
        def edit
          authorize! :update, @account
        end

        # POST /accounts
        def create
          @account = Account.new(account_params)
          
          authorize! :create, @account
          
          @account.creator = current_user
          @account.set_active

          if @account.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @account.name,
                value: @account.id
              }
            else
              redirect_to erp_payments.backend_accounts_path, notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /accounts/1
        def update
          authorize! :update, @account
          
          if @account.update(account_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @account.name,
                value: @account.id
              }
            else
              redirect_to erp_payments.backend_accounts_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /accounts/1
        #def destroy
        #  @account.destroy
        #
        #  respond_to do |format|
        #    format.html { redirect_to erp_payments.backend_accounts_path, notice: t('.success') }
        #    format.json {
        #      render json: {
        #        'message': t('.success'),
        #        'type': 'success'
        #      }
        #    }
        #  end
        #end

        # Archive /accounts/archive?id=1
        def archive
          authorize! :archive, @account
          
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
          authorize! :unarchive, @account
          
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
        #def delete_all
        #  @accounts.destroy_all
        #
        #  respond_to do |format|
        #    format.json {
        #      render json: {
        #        'message': t('.success'),
        #        'type': 'success'
        #      }
        #    }
        #  end
        #end

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

        # Set active /accounts/active?id=1
        def set_active
          authorize! :set_active, @account
          
          @account.set_active
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

        # Set deleted /accounts/deleted?id=1
        def set_deleted
          authorize! :set_deleted, @account
          
          @account.set_deleted
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
            params.fetch(:account, {}).permit(:code, :name, :account_number, :owner, :payment_method)
          end
      end
    end
  end
end
