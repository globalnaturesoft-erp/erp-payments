require_dependency "erp/application_controller"

module Erp
  module Payments
    module Backend
      class DebtsController < Erp::Backend::BackendController
        before_action :set_debt, only: [:archive, :unarchive, :edit, :update, :destroy]
        before_action :set_debts, only: [:delete_all, :archive_all, :unarchive_all]
    
        # POST /debts/list
        def list
          @debts = Debt.search(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
        
        def order_debt_list
          @debts = Debt.get_order_debts(params).search(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
    
        # GET /debts/new
        def new
          @debt = Debt.new
        end
    
        # GET /debts/1/edit
        def edit
        end
    
        # POST /debts
        def create
          @debt = Debt.new(debt_params)
          @debt.creator = current_user
    
          if @debt.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @debt.deadline,
                value: @debt.id
              }
            else
              redirect_to erp_payments.edit_backend_debt_path(@debt, order_id: @debt.order_id), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /debts/1
        def update
          if @debt.update(debt_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @debt.name,
                value: @debt.id
              }              
            else
              redirect_to erp_payments.edit_backend_debt_path(@debt, order_id: @debt.order_id), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /debts/1
        def destroy
          @debt.destroy
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_debts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def archive
          @debt.archive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_debts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def unarchive
          @debt.unarchive
          respond_to do |format|
            format.html { redirect_to erp_payments.backend_debts_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # DELETE /debts/delete_all?ids=1,2,3
        def delete_all         
          @debts.destroy_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Archive /debts/archive_all?ids=1,2,3
        def archive_all         
          @debts.archive_all
          
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end          
        end
        
        # Unarchive /debts/unarchive_all?ids=1,2,3
        def unarchive_all
          @debts.unarchive_all
          
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
              render json: Debt.dataselect(params[:keyword])
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_debt
            @debt = Debt.find(params[:id])
          end
          
          def set_debts
            @debts = Debt.where(id: params[:ids])
          end
    
          # Only allow a trusted parameter "white list" through.
          def debt_params
            params.fetch(:debt, {}).permit(:order_id, :deadline, :note)
          end
      end
    end
  end
end
