require_dependency "erp/backend/backend_controller"

module Erp
  module Payments
    module Backend
      class PaymentMethodsController < Erp::Backend::BackendController
        before_action :set_payment_method, only: [:archive, :unarchive, :edit, :update, :destroy]
        before_action :set_payment_methods, only: [:delete_all, :archive_all, :unarchive_all]
        
        # GET /payment_methods
        def index
        end
        
        # POST /payment_methods/list
        def list
          @payment_methods = PaymentMethod.search(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
    
        # GET /payment_methods/new
        def new
          @payment_method = PaymentMethod.new
        end
    
        # GET /payment_methods/1/edit
        def edit
        end
    
        # POST /payment_methods
        def create
          @payment_method = PaymentMethod.new(payment_method_params)
          @payment_method.creator = current_user
    
          if @payment_method.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_method.name,
                value: @payment_method.id
              }
            else
              redirect_to erp_payments.edit_backend_payment_method_path(@payment_method), notice: t('.success')
            end
          else
            render :new        
          end
        end
    
        # PATCH/PUT /payment_methods/1
        def update
          if @payment_method.update(payment_method_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_method.name,
                value: @payment_method.id
              }              
            else
              redirect_to erp_payments.edit_backend_payment_method_path(@payment_method), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /payment_methods/1
        def destroy
          @payment_method.destroy

          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_methods_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def archive
          @payment_method.archive
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def unarchive
          @payment_method.unarchive
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE /payment_methods/delete_all?ids=1,2,3
        def delete_all         
          @payment_methods.destroy_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Archive /payment_methods/archive_all?ids=1,2,3
        def archive_all         
          @payment_methods.archive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Unarchive /payment_methods/unarchive_all?ids=1,2,3
        def unarchive_all
          @payment_methods.unarchive_all
          
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
              render json: PaymentMethod.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_payment_method
            @payment_method = PaymentMethod.find(params[:id])
          end
          
          def set_payment_methods
            @payment_methods = PaymentMethod.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def payment_method_params
            params.fetch(:payment_method, {}).permit(:name, :type_method, :is_default)
          end
      end
    end
  end
end
