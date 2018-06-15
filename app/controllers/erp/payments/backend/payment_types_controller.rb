module Erp
  module Payments
    module Backend
      class PaymentTypesController < Erp::Backend::BackendController
        before_action :set_payment_type, only: [:edit, :update, :set_active, :set_deleted]

        # POST /payment_types/list
        def list
          @payment_types = PaymentType.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /payment_types/new
        def new
          @payment_type = PaymentType.new
          #@payment_type.code = Erp::Payments::PaymentType::CODE_CUSTOM
        end

        # GET /payment_types/1/edit
        def edit
        end

        # POST /payment_types
        def create
          @payment_type = PaymentType.new(payment_type_params)

          if @payment_type.save
            @payment_type.set_code_is_custom
            @payment_type.set_active
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_type.name,
                value: @payment_type.id
              }
            else
              redirect_to erp_payments.backend_payment_types_path, notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /payment_types/1
        def update
          if @payment_type.update(payment_type_params)
            #@payment_type.set_code_is_custom

            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_type.name,
                value: @payment_type.id
              }
            else
              redirect_to erp_payments.backend_payment_types_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # ACTIVE /payment_records/1
        def set_active
          @payment_type.set_active
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_types_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # DELETED /payment_records/1
        def set_deleted
          @payment_type.set_deleted
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_types_path, notice: t('.success') }
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
              render json: PaymentType.dataselect(params[:keyword], params)
            }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_payment_type
            @payment_type = PaymentType.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def payment_type_params
            params.fetch(:payment_type, {}).permit(:name, :is_payable, :is_receivable, :status,
                        :payment_type_limits_attributes => [ :id, :period_id, :amount, :_destroy ])
          end
      end
    end
  end
end
