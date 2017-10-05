module Erp
  module Payments
    module Backend
      class PaymentRecordsController < Erp::Backend::BackendController
        before_action :set_payment_record, only: [:show, :edit, :update, :set_done, :set_deleted]
        before_action :set_payment_records, only: [:set_done_all, :set_deleted_all]
    
        # GET /payment_records
        def index
        end
    
        # POST /payment_records/list
        def list
          records = PaymentRecord.search(params)
          
           #todo get dates from params
          from_date = Time.now.beginning_of_month.beginning_of_day
          to_date = Time.now.end_of_month.end_of_day
          
          # Recieved total
          @total_received = records.received_amount(from_date, to_date)
          
          # Paid total
          @total_paid = records.paid_amount(from_date, to_date)
          
          # Begin of period amount
          @begin_period_amount = records.remain_amount(nil, (from_date - 1.day).end_of_day)
          
          # End of period amount
          @end_period_amount = records.remain_amount(nil, to_date)
          
          @payment_records = records.paginate(:page => params[:page], :per_page => 3)
          
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
          @payment_record.accountant = current_user
          
          if params[:contact_id].present?
            @payment_record.contact = Erp::Contacts::Contact.find(params[:contact_id])
          end
          
          if params[:payment_type_id].present?
            @payment_record.payment_type = Erp::Payments::PaymentType.find(params[:payment_type_id])
          end
          
          if params[:pay_receive].present?
            @payment_record.pay_receive = params[:pay_receive]
          end
          
          if Erp::Core.available?("orders")
            if params[:order_id].present?
              if Erp::Orders::Order.find(params[:order_id]).sales?
                @payment_record.contact_id = Erp::Orders::Order.find(params[:order_id]).customer_id
              elsif Erp::Orders::Order.find(params[:order_id]).purchase?
                @payment_record.contact_id = Erp::Orders::Order.find(params[:order_id]).supplier_id
              end
              @payment_record.order = Erp::Orders::Order.find(params[:order_id])
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
            @payment_record.set_done
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
        
        # DONE /payment_records/1
        def set_done
          @payment_record.set_done
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
        
        # DELETED /payment_records/1
        def set_deleted
          @payment_record.set_deleted
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
        
        # DONE /payment_records/set_done_all?ids=1,2,3
        def set_done_all
          @payment_records.set_done_all
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
        
        # DELETED /payment_records/set_deleted_all?ids=1,2,3
        def set_deleted_all
          @payment_records.set_deleted_all
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
        
        def ajax_info_form_for_order
          @order = Erp::Orders::Order.where(id: params[:datas][0]).first
          @contact = @order.customer
          render layout: false
        end
        
        def ajax_info_form_for_contact
          @contact = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          render layout: false
        end
        
        def ajax_info_form_for_commission
        end
        
        # liabilities tracking table
        def liabilities_tracking_table
          glb = params.to_unsafe_hash[:global_filter]
          @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
          @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          
          if glb[:customer].present?
            @contacts = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @contacts = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
          end
        end
        
        # liabilities tracking table details
        def liabilities_tracking_table_details
          @orders = Erp::Contacts::Contact.find(params[:contact_id]).sales_orders_is_payment_for_contact
          @payment_records = Erp::Payments::PaymentRecord.where(contact_id: params[:contact_id])
        end
        
        # commission
        def commission_table
          @employees = Erp::User.where('id != ?', Erp::User.find_by_email('admin@globalnaturesoft.com').id)
        end
        
        def commission_details
          @orders = Erp::Orders::Order.where(payment_for: Erp::Payments::PaymentType::TYPE_FOR_ORDER)
          @contacts = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
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
            params.fetch(:payment_record, {}).permit(:code, :amount, :payment_date, :pay_receive, :description, :status,
                                                     :order_id, :accountant_id, :contact_id, :employee_id, :account_id, :payment_type_id)
          end
      end
    end
  end
end
