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
          @total_received = 10000000000#records.received_amount(from_date, to_date)
          
          # Paid total
          @total_paid = 10000000000#records.paid_amount(from_date, to_date)
          
          # Begin of period amount
          @begin_period_amount = 10000000000#records.remain_amount(nil, (from_date - 1.day).end_of_day)
          
          # End of period amount
          @end_period_amount = 10000000000#records.remain_amount(nil, to_date)
          
          @payment_records = records.paginate(:page => params[:page], :per_page => 20)
          
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
          
          if params[:customer_id].present?
            @payment_record.customer = Erp::Contacts::Contact.find(params[:customer_id])
          end
          
          if params[:supplier_id].present?
            @payment_record.supplier = Erp::Contacts::Contact.find(params[:supplier_id])
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
                @payment_record.customer_id = Erp::Orders::Order.find(params[:order_id]).customer_id
              elsif Erp::Orders::Order.find(params[:order_id]).purchase?
                @payment_record.supplier_id = Erp::Orders::Order.find(params[:order_id]).supplier_id
              end
              @payment_record.order = Erp::Orders::Order.find(params[:order_id])
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
          @contact = @order.customer if @order.sales?
          @contact = @order.supplier if @order.purchase?
          render layout: false
        end
        
        def ajax_info_form_for_customer
          @customer = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          render layout: false
        end
        
        def ajax_info_form_for_supplier
          @supplier = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          render layout: false
        end
        
        def ajax_info_form_for_commission
        end
        
        def ajax_info_form_for_customer_commission
          @customer = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          render layout: false
        end
        
        def ajax_amount_field
          @order = Erp::Orders::Order.where(id: params[:datas][0]).first
          @customer = Erp::Contacts::Contact.where(id: params[:datas][1]).first
          @supplier = Erp::Contacts::Contact.where(id: params[:datas][2]).first
          if params[:amount].present?
            @amount = params[:amount]
          else
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_SALES_ORDER
              @amount = @order.remain_amount if @order.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_PURCHASE_ORDER
              @amount = @order.remain_amount if @order.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_CUSTOMER
              @amount = @customer.sales_debt_amount(to_date: Time.now) if @customer.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_SUPPLIER
              @amount = @supplier.purchase_debt_amount(to_date: Time.now) if @supplier.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION
              @amount = @customer.customer_commission_debt_amount(to_date: Time.now) if @customer.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_CUSTOM
              @amount = nil
            end
          end
        end
        
        def ajax_employee_field
            # Payment record da ton tai employee
            if params[:employee_id].present?
              @employee = Erp::User.find(params[:employee_id])
            
            # Payment record chua ton tai employee
            # Lay employee theo order (payment for order)
            elsif params[:type] == 'order' and params[:datas].present? and params[:datas][0].present?
              @order = Erp::Orders::Order.where(id: params[:datas][0]).first
              if @order.present? and @order.employee_id.present?
                @employee = Erp::User.find(@order.employee_id)
              else
                @employee = Erp::User.new
              end
            
            # Lay employee theo contact (payment for contact)
            elsif params[:type] == 'contact' and params[:datas].present? and params[:datas][0].present?
              @contact = Erp::Contacts::Contact.where(id: params[:datas][0]).first
              
              if @contact.present? and @contact.salesperson_id.present?
                @employee = Erp::User.find(@contact.salesperson_id)
              else
                @employee = Erp::User.new
              end
              
            else # Tra ve gia tri rong neu employee khong ton tai
              @employee = Erp::User.new
            end
          render layout: false
        end
        
        # CUSTOMER / liabilities tracking table
        def liabilities_tracking_table
          glb = params.to_unsafe_hash[:global_filter]
          @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
          @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          
          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
                                              .where(is_customer: true)
          end
        end
        
        # CUSTOMER / liabilities tracking table details
        def liabilities_tracking_table_details
          @orders = Erp::Contacts::Contact.find(params[:customer_id]).sales_orders.payment_for_contact_orders
          @payment_records = Erp::Payments::PaymentRecord.where(customer_id: params[:customer_id])
                                                        .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
        end
        
        # SUPPLIER / liabilities tracking table
        def supplier_liabilities_tracking_table
          glb = params.to_unsafe_hash[:global_filter]
          @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
          @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          
          if glb[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: glb[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
                                              .where(is_supplier: true)
          end
        end
        
        # SUPPLIER / liabilities tracking table details
        def supplier_liabilities_tracking_table_details
          @orders = Erp::Contacts::Contact.find(params[:supplier_id]).purchase_orders.payment_for_contact_orders
          @payment_records = Erp::Payments::PaymentRecord.where(supplier_id: params[:supplier_id])
                                                        .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER).id)
        end
        
        # commission / SALESPERSON
        def commission_table
          # @todo change user 'admin@globalnaturesoft.com'
          @employees = Erp::User.where('id != ?', Erp::User.find_by_email('admin@globalnaturesoft.com').id)
        end
        
        def commission_details
          @orders = Erp::Orders::Order.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER)
          @contacts = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
        end
        
        # commission / CUSTOMER
        def customer_commission_table
          glb = params.to_unsafe_hash[:global_filter]
          @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
          @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          
          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
                                              .where(is_customer: true)
          end
        end
        
        def customer_commission_details
          @orders = Erp::Contacts::Contact.find(params[:customer_id]).sales_orders.payment_for_contact_orders
          @payment_records = Erp::Payments::PaymentRecord.where(customer_id: params[:customer_id])
                                                        .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION).id)
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
                                                     :order_id, :accountant_id, :customer_id, :supplier_id, :employee_id, :account_id, :payment_type_id)
          end
      end
    end
  end
end
