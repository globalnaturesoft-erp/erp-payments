require_dependency "erp/application_controller"

module Erp
  module Payments
    module Backend
      class PaymentTermsController < Erp::Backend::BackendController
        before_action :set_payment_term, only: [:archive, :unarchive, :edit, :update, :destroy]
        before_action :set_payment_terms, only: [:delete_all, :archive_all, :unarchive_all]
        
        # GET /payment_terms
        def index
        end
        
        # POST /payment_terms/list
        def list
          @payment_terms = PaymentTerm.search(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
    
        # GET /payment_terms/new
        def new
          @payment_term = PaymentTerm.new
        end
    
        # GET /payment_terms/1/edit
        def edit
        end
    
        # POST /payment_terms
        def create
          @payment_term = PaymentTerm.new(payment_term_params)
          @payment_term.creator = current_user
    
          if @payment_term.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_term.name,
                value: @payment_term.id
              }
            else
              redirect_to erp_payments.edit_backend_payment_term_path(@payment_term), notice: t('.success')
            end
          else
            render :new        
          end
        end
    
        # PATCH/PUT /payment_terms/1
        def update
          if @payment_term.update(payment_term_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_term.name,
                value: @payment_term.id
              }              
            else
              redirect_to erp_payments.edit_backend_payment_term_path(@payment_term), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /payment_terms/1
        def destroy
          @payment_term.destroy

          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_terms_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def archive
          @payment_term.archive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_terms_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def unarchive
          @payment_term.unarchive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_payment_terms_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE /payment_terms/delete_all?ids=1,2,3
        def delete_all         
          @payment_terms.destroy_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Archive /payment_terms/archive_all?ids=1,2,3
        def archive_all         
          @payment_terms.archive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Unarchive /payment_terms/unarchive_all?ids=1,2,3
        def unarchive_all
          @payment_terms.unarchive_all
          
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
              render json: PaymentTerm.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_payment_term
            @payment_term = PaymentTerm.find(params[:id])
          end
          
          def set_payment_terms
            @payment_terms = PaymentTerm.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def payment_term_params
            params.fetch(:payment_term, {}).permit(:name, :timeout, :started_on, :is_default)
          end
      end
    end
  end
end
