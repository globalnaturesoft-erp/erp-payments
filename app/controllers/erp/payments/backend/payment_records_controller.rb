require_dependency "erp/application_controller"

module Erp
  module Payments
    module Backend
      class PaymentRecordsController < Erp::Backend::BackendController
        before_action :set_payment_record, only: [:confirm, :show, :edit, :update, :destroy]
        before_action :set_payment_records, only: [:confirm_all, :delete_all]
    
        # GET /payment_records
        def index
        end
    
        # POST /payment_records/list
        def list
          @payment_records = PaymentRecord.all.paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
        
        def order_payment_record_list
          @payment_records = PaymentRecord.get_order_payment_records(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
    
        # GET /payment_records/new
        def new
          @payment_record = PaymentRecord.new
          @payment_record.payment_date = Time.now
          @payment_record.status = Erp::Payments::PaymentRecord::STATUS_PENDING
          @payment_record.accountant_id = current_user.id
          if Erp::Core.available?("orders")
            if params[:order_id].present?
              if Erp::Orders::Order.find(params[:order_id]).sales?
                @payment_record.contact_id = Erp::Orders::Order.find(params[:order_id]).customer_id
              elsif Erp::Orders::Order.find(params[:order_id]).purchase?
                @payment_record.contact_id = Erp::Orders::Order.find(params[:order_id]).supplier_id
              end
              @payment_record.amount = Erp::Orders::Order.find(params[:order_id]).remain_amount
            end
          end
        end
    
        # GET /payment_records/1/edit
        def edit
        end
        
        # GET /payment_records/1/show
        def show
        end
    
        # POST /payment_records
        def create
          @payment_record = PaymentRecord.new(payment_record_params)
          @payment_record.creator = current_user
    
          if @payment_record.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_record.code,
                value: @payment_record.id
              }
            else
              redirect_to erp_payments.backend_payment_record_path(@payment_record), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /payment_records/1
        def update
          if @payment_record.update(payment_record_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_record.code,
                value: @payment_record.id
              }              
            else
              redirect_to erp_payments.backend_payment_record_path(@payment_record), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /payment_records/1
        def destroy
          @payment_record.destroy
          
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_records_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE /payment_records/delete_all?ids=1,2,3
        def delete_all         
          @payment_records.destroy_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # CONFIRM /payment_records/1
        def confirm
          @payment_record.confirm
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_records_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # CONFIRM /payment_records/confirm_all?ids=1,2,3
        def confirm_all
          @payment_records.confirm_all
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_records_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_payment_record
            @payment_record = PaymentRecord.find(params[:id])
          end
          
          def set_payment_records
            @payment_records = PaymentRecord.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def payment_record_params
            params.fetch(:payment_record, {}).permit(:code, :amount, :payment_date, :payment_type, :description, :status, :order_id, :accountant_id, :contact_id)
          end
      end
    end
  end
end
