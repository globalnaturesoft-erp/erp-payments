module Erp
  module Payments
    module Backend
      class PaymentTypesController < Erp::Backend::BackendController
        before_action :set_payment_type, only: [:edit, :update]
        
        # POST /payment_types/list
        def list
          @payment_types = PaymentType.search(params).paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end
    
        # GET /payment_types/new
        def new
          @payment_type = PaymentType.new
        end
    
        # GET /payment_types/1/edit
        def edit
        end
    
        # POST /payment_types
        def create
          @payment_type = PaymentType.new(payment_type_params)
          
          if @payment_type.save
            @payment_type.set_code_is_custom
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_type.name,
                value: @payment_type.id
              }
            else
              redirect_to erp_payments.edit_backend_payment_type_path(@payment_type), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /payment_types/1
        def update
          if @payment_type.update(payment_type_params)
            @payment_type.set_code_is_custom
            
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_type.name,
                value: @payment_type.id
              }              
            else
              redirect_to erp_payments.edit_backend_payment_type_path(@payment_type), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_payment_type
            @payment_type = PaymentType.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def payment_type_params
            params.fetch(:payment_type, {}).permit(:name)
          end
      end
    end
  end
end
