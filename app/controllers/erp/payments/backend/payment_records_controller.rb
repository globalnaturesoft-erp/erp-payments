module Erp
  module Payments
    module Backend
      class PaymentRecordsController < Erp::Backend::BackendController
        before_action :set_payment_record, only: [:pdf, :show, :show_list, :show_modal, :edit, :update, :set_done, :set_deleted]
        before_action :set_payment_records, only: [:set_done_all, :set_deleted_all]

        # GET /payment_records
        def index
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day
        end

        # POST /payment_records/list
        def list
          records = PaymentRecord.search(params)

          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end

          #todo get dates from params
          #from_date = Time.now.beginning_of_month.beginning_of_day
          #to_date = Time.now.end_of_month.end_of_day

          # Recieved total
          @total_received = records.received_amount(from_date: @from, to_date: @to)

          # Paid total
          @total_paid = records.paid_amount(from_date: @from, to_date: @to)
          
          @differences = records.remain_amount(from_date: @from, to_date: @to)

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
          @payment_record.payment_date = params[:payment_date] if params[:payment_date].present?
          @payment_record.accountant = current_user

          if params[:customer_id].present?
            @payment_record.customer = Erp::Contacts::Contact.find(params[:customer_id])
          end

          if params[:supplier_id].present?
            @payment_record.supplier = Erp::Contacts::Contact.find(params[:supplier_id])
          end

          if params[:delivery_id].present?
            @payment_record.delivery = Erp::Qdeliveries::Delivery.find(params[:delivery_id])
          end

          if params[:payment_type_id].present?
            @payment_record.payment_type = Erp::Payments::PaymentType.find(params[:payment_type_id])
          end

          if params[:account_id].present?
            @payment_record.account = Erp::Payments::Account.find(params[:account_id])
          end

          if params[:pay_receive].present?
            @payment_record.pay_receive = params[:pay_receive]
          end

          if params[:employee_id].present?
            @payment_record.employee_id = params[:employee_id]
          end

          if params[:period_id].present?
            @period = Erp::Periods::Period.find(params[:period_id])
            @payment_record.period_id = params[:period_id]
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
          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "show_list",
                layout: 'erp/backend/pdf'
            end
          end
        end

        def show_list
        end

        # GET /orders/1
        def pdf

          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "#{@payment_record.code}",
                title: "#{@payment_record.code}",
                layout: 'erp/backend/pdf',
                page_size: 'A5',
                orientation: 'Landscape',
                margin: {
                  top: 10,                     # default 10 (mm)
                  bottom: 7,
                  left: 7,
                  right: 7
                }
            end
          end
        end

        # POST /payment_records
        def create
          @payment_record = PaymentRecord.new(payment_record_params)
          @payment_record.creator = current_user
          @payment_record.status = PaymentRecord::STATUS_DONE

          if @payment_record.save

            if request.xhr?
              render json: {
                status: 'success',
                text: @payment_record.code,
                value: @payment_record.id
              }
            else
              if params.to_unsafe_hash[:save_print].present?
                redirect_to erp_payments.backend_payment_record_path(@payment_record), notice: t('.success')
              else
                redirect_to erp_payments.backend_payment_records_path, notice: t('.success')
              end
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
              if params.to_unsafe_hash[:save_print].present?
                redirect_to erp_payments.backend_payment_record_path(@payment_record), notice: t('.success')
              else
                redirect_to erp_payments.backend_payment_records_path, notice: t('.success')
              end
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
          if @order.present?
            @contact = @order.customer if @order.sales?
            @contact = @order.supplier if @order.purchase?
          end
          render layout: false
        end

        def ajax_info_form_for_customer
          @customer = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          #@period = Erp::Periods::Period.where(id: params[:datas][1]).first
          @period = Erp::Periods::Period.where(id: params[:form_data][:payment_record][:period_id]).first
          
          @period_id = @period.id if @period.present?
          @from_date = @period.present? ? @period.from_date.beginning_of_day : nil
          @to_date = @period.present? ? @period.to_date.end_of_day : Time.now
            
          render layout: false
        end

        def ajax_info_form_for_supplier
          @supplier = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          @period = Erp::Periods::Period.where(id: params[:form_data][:payment_record][:period_id]).first
          
          @period_id = @period.id if @period.present?
          @from_date = @period.present? ? @period.from_date.beginning_of_day : nil
          @to_date = @period.present? ? @period.to_date.end_of_day : Time.now
          
          render layout: false
        end

        def ajax_info_form_for_commission
          @options = {}
          if params[:period_id].present?
            @period = Erp::Periods::Period.find(params[:period_id])

            @options = {
              from_date: @period.from_date.beginning_of_day,
              to_date: @period.to_date.end_of_day,
              target_period: @period,
            }
          end

          @employee = Erp::User.where(id: params[:datas][0]).first
        end

        def ajax_info_form_for_customer_commission
          @customer = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          render layout: false
        end

        def ajax_info_form_for_delivery
          @delivery = Erp::Qdeliveries::Delivery.where(id: params[:datas][0]).first
          @contact = @delivery.customer if @delivery.present?
          render layout: false
        end

        def ajax_payment_type_limits_info
          @payment_date = params[:datas][0]
          if params[:payment_type_id].present?
            @payment_type = Erp::Payments::PaymentType.find(params[:payment_type_id])
            @payment_type_limits = @payment_type.get_limits(date: @payment_date)
          end
          #@contact = @delivery.customer
          render layout: false
        end

        def ajax_amount_field
          @order = Erp::Orders::Order.where(id: params[:datas][0]).first
          @customer = Erp::Contacts::Contact.where(id: params[:datas][1]).first
          @supplier = Erp::Contacts::Contact.where(id: params[:datas][2]).first
          @delivery = Erp::Qdeliveries::Delivery.where(id: params[:datas][3]).first
          @employee = Erp::User.where(id: params[:datas][4]).first
          
          @period = Erp::Periods::Period.where(id: params[:form_data][:payment_record][:period_id]).first
          @period_id = @period.id if @period.present?
          
          @from_date = @period.present? ? @period.from_date.beginning_of_day : nil
          @to_date = @period.present? ? @period.to_date.end_of_day : Time.now
          
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
              @amount = @customer.sales_debt_amount(from_date: @from_date, to_date: @to_date, period_id: @period_id) if @customer.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_SUPPLIER
              @amount = @supplier.purchase_debt_amount(from_date: @from_date, to_date: @to_date) if @supplier.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION
              @amount = @customer.customer_commission_debt_amount(to_date: Time.now) if @customer.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_PRODUCT_RETURN
              @amount = @delivery.remain_amount if @delivery.present?
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_CUSTOM
              @amount = nil
            end
            if params[:payment_type_code] == Erp::Payments::PaymentType::CODE_COMMISSION
              @amount = @employee.commission_remain_amount if @employee.present?
              if params[:period_id].present?
                @period = Erp::Periods::Period.find(params[:period_id])

                @options = {
                  from_date: @period.from_date.beginning_of_day,
                  to_date: @period.to_date.end_of_day,
                  target_period: @period,
                }

                @amount = @employee.commission_remain_amount(@options) if @employee.present?
              end
            end
          end
        end

        def ajax_address_field
          @customer = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          @supplier = Erp::Contacts::Contact.where(id: params[:datas][1]).first
          @employee = Erp::User.where(id: params[:datas][2]).first
          @order = Erp::Orders::Order.where(id: params[:datas][3]).first
          @delivery = Erp::Qdeliveries::Delivery.where(id: params[:datas][4]).first
          
          if @customer.present?
            @address = view_context.display_contact_address(@customer)
          end
          
          if @supplier.present?
            @address = view_context.display_contact_address(@supplier)
          end
          
          if @employee.present?
            @address = (@employee.contact.nil? ? @employee.address : view_context.display_contact_address(@employee.contact))
          end
          
          if @order.present?
            if @order.sales?
              @address = view_context.display_contact_address(@order.customer)
            else
              @address = view_context.display_contact_address(@order.supplier)
            end
          end
          
          if @delivery.present?
            @address = view_context.display_contact_address(@delivery.customer) if [
              Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT,
              Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT].include?(@delivery.delivery_type)
            @address = view_context.display_contact_address(@delivery.supplier) if [
              Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT,
              Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT].include?(@delivery.delivery_type)
            @address = @delivery.address if !@delivery.address.nil?
          end
          
          @is_edit = params[:payment_record_id].present? ? true : false
          @new_address = @address
          @address = params[:address] if params[:address].present?
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
        
        # CUSTOMER / orders tracking table
        def sales_orders_tracking_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          @customers = Erp::Contacts::Contact.search(params)
            .where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          
          if glb[:contact_group_id].present?
            @customers = @customers.where(contact_group_id: glb[:contact_group_id])
          end
          
          if glb[:customer].present?
            @customers = @customers.where(id: glb[:customer])
          else
            @customers = @customers.where(is_customer: true)
          end
          
          #filters
          if params.to_unsafe_hash["filters"].present?
            params.to_unsafe_hash["filters"].each do |ft|
              ft[1].each do |cond|
                if cond[1]["name"] == 'in_period_active'
                  @customers = @customers.get_sales_orders_tracking_payment_chasing_contacts(
                    from_date: @from,
                    to_date: @to
                  )
                end
              end
            end
          end
          
          @full_customers = @customers
          
          @customers = @customers.paginate(:page => params[:page], :per_page => 20)
        end
        
        # CUSTOMER / orders tracking table details
        def sales_orders_tracking_table_details
        end
        
        def sales_orders_tracking_payment_records_list
          @payment_records = Erp::Payments::PaymentRecord.all_done
            .where(customer_id: params[:customer_id])
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id)

          # from to date
          if params[:from_date].present?
            @payment_records = @payment_records.where('payment_date >= ?', params[:from_date].to_date.beginning_of_day)
          end

          if params[:to_date].present?
            @payment_records = @payment_records.where('payment_date <= ?', params[:to_date].to_date.end_of_day)
          end
          @full_payment_records = @payment_records
          @payment_records = @payment_records.paginate(:page => params[:page], :per_page => 10)
        end
        
        def sales_orders_tracking_sales_export_list
          @orders = Erp::Contacts::Contact.find(params[:customer_id]).sales_orders
            .payment_for_order_orders(params.to_unsafe_hash)
          @full_orders = @orders
          @orders = @orders.paginate(:page => params[:page], :per_page => 10)
        end
        
        def sales_orders_tracking_sales_import_list
          @product_returns = Erp::Contacts::Contact.find(params[:customer_id]).sales_product_returns
            .get_deliveries_with_payment_for_order(params.to_unsafe_hash)
          @full_product_returns = @product_returns
          @product_returns = @product_returns.paginate(:page => params[:page], :per_page => 10)
        end
        
        # SUPPLIER / orders tracking table
        def purchase_orders_tracking_table
        end

        # CUSTOMER / liabilities tracking table
        def liabilities_tracking_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date.beginning_of_day : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date.end_of_day : Time.now.end_of_month
          end

          @customers = Erp::Contacts::Contact.search(params)
            .where.not(id: Erp::Contacts::Contact.get_main_contact.id)
            
          @customers = @customers.where(is_customer: true)
          
          if glb[:customer].present?
            @customers = @customers.where(id: glb[:customer])
          end

          #filters
          if params.to_unsafe_hash["filters"].present?
            params.to_unsafe_hash["filters"].each do |ft|
              ft[1].each do |cond|
                if cond[1]["name"] == 'in_period_active'
                  @customers = @customers.get_sales_payment_chasing_contacts
                  #(
                  #  from_date: @from,
                  #  to_date: @to
                  #)
                end
              end
            end
          end
          
          @full_customers = @customers
          
          @customers = @customers.paginate(:page => params[:page], :per_page => 20)
        end

        # CUSTOMER / liabilities tracking table details
        def liabilities_tracking_table_details
        end
        
        def liabilities_tracking_payment_records_list          
          @payment_records = Erp::Payments::PaymentRecord.all_done
            .where(customer_id: params[:customer_id])
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
          
          if params[:from_date].present?
            @payment_records = @payment_records.where('payment_date >= ?', params[:from_date].to_date.beginning_of_day)
          end
          
          if params[:to_date].present?
            @payment_records = @payment_records.where('payment_date <= ?', params[:to_date].to_date.end_of_day)
          end
            
          @full_payment_records = @payment_records
          
          @payment_records = @payment_records.order('payment_date DESC, created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end
        
        def liabilities_tracking_sales_export_list
          @orders = Erp::Contacts::Contact.find(params[:customer_id]).sales_orders
            .payment_for_contact_orders(params.to_unsafe_hash)
          
          @full_orders = @orders
          
          @orders = @orders.order('order_date DESC, created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end
        
        def liabilities_tracking_sales_import_list
          @product_returns = Erp::Contacts::Contact.find(params[:customer_id]).sales_product_returns
            .get_deliveries_with_payment_for_contact(params.to_unsafe_hash)
          
          @full_product_returns = @product_returns
          
          @product_returns = @product_returns.order('date DESC, created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end

        # SUPPLIER / liabilities tracking table
        def supplier_liabilities_tracking_table          
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date.beginning_of_day : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date.end_of_day : Time.now.end_of_month
          end
          
          @suppliers = Erp::Contacts::Contact.search(params)
            .where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          
          if glb[:contact_group_id].present?
            @suppliers = @suppliers.where(contact_group_id: glb[:contact_group_id])
          end

          if glb[:supplier].present?
            @suppliers = @suppliers.where(id: glb[:supplier])
          else
            @suppliers = @suppliers.where(is_supplier: true)
          end

          # only suppliers with records
          #filters
          if params.to_unsafe_hash["filters"].present?
            params.to_unsafe_hash["filters"].each do |ft|
              ft[1].each do |cond|
                if cond[1]["name"] == 'in_period_active'
                  @suppliers = @suppliers.get_purchase_payment_chasing_contacts
                  #(
                  #  from_date: @from,
                  #  to_date: @to
                  #)
                end
              end
            end
          end
          
          @full_suppliers = @suppliers
          
          @suppliers = @suppliers.paginate(:page => params[:page], :per_page => 20)
        end

        # SUPPLIER / liabilities tracking table details
        def supplier_liabilities_tracking_table_details
        end
        
        def supplier_liabilities_tracking_payment_records_list
          @payment_records = Erp::Payments::PaymentRecord.all_done
            .where(supplier_id: params[:supplier_id])
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER).id)
          
          if params[:from_date].present?
            @payment_records = @payment_records.where('payment_date >= ?', params[:from_date].to_date.beginning_of_day)
          end
          
          if params[:to_date].present?
            @payment_records = @payment_records.where('payment_date <= ?', params[:to_date].to_date.end_of_day)
          end
            
          @full_payment_records = @payment_records
          
          @payment_records = @payment_records.order('payment_date DESC, created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end
        
        def supplier_liabilities_tracking_purchase_import_list
          @orders = Erp::Contacts::Contact.find(params[:supplier_id])
            .purchase_orders
            .payment_for_contact_orders(params.to_unsafe_hash)
          
          @full_orders = @orders
          
          @orders = @orders.order('erp_orders_orders.order_date DESC, erp_orders_orders.created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end
        
        def supplier_liabilities_tracking_purchase_export_list
          @product_returns = Erp::Contacts::Contact.find(params[:supplier_id])
            .purchase_product_returns
            .get_deliveries_with_payment_for_contact(params.to_unsafe_hash)
          
          @full_product_returns = @product_returns
          
          @product_returns = @product_returns.order('erp_qdeliveries_deliveries.date DESC, erp_qdeliveries_deliveries.created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end

        # commission / SALESPERSON
        def commission_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])

            @options = {
              from_date: @period.from_date.beginning_of_day,
              to_date: @period.to_date.end_of_day,
              target_period: @period,
            }

            @company_target = Erp::Targets::CompanyTarget.get_by_period(@period)
          end

          # @todo change user 'admin@globalnaturesoft.com'
          @employees = Erp::User.where('erp_users.id NOT IN (?)', Erp::User.first.id)
          @employees = Erp::User.where(id: @global_filters[:employee]) if @global_filters[:employee].present?
          
          @employees = @employees.paginate(:page => params[:page], :per_page => 10)
        end

        def commission_details
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])

            @orders = Erp::Orders::Order.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER)
            @contacts = Erp::Contacts::Contact.where('erp_contacts_contacts.id NOT IN (?)', Erp::Contacts::Contact.get_main_contact.id)
            @employee = Erp::User.find(params[:employee_id])

            @options = {
              from_date: @period.from_date.beginning_of_day,
              to_date: @period.to_date.end_of_day,
              target_period: @period,
            }

            # payment for order orders
            @payment_for_order_sales_payment_records = @employee.payment_for_order_sales_payment_records(@options)
            @payment_for_order_sales_total = @employee.payment_for_order_sales_total(@options)
            @payment_for_order_sales_paid_amount = @employee.payment_for_order_sales_paid_amount(@options)
            @payment_for_order_sales_commission_amount = @employee.payment_for_order_sales_commission_amount(@options)

            # payment for contact orders
            @payment_for_contact_sales_payment_records = @employee.payment_for_contact_sales_payment_records(@options).order('payment_date')
            @payment_for_contact_sales_paid_amount = @employee.payment_for_contact_sales_paid_amount(@options)
            @payment_for_contact_sales_commission_amount = @employee.payment_for_contact_sales_commission_amount(@options)
            @new_account_commission_amount = @employee.new_account_commission_amount(@options)

            # target
            @target = @employee.target_by_period(@period)
            @company_target = Erp::Targets::CompanyTarget.get_by_period(@period)
          end
        end

        # commission / CUSTOMER
        def customer_commission_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date.beginning_of_day : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date.end_of_day : Time.now.end_of_month
            @period_name = nil
          end

          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where('erp_contacts_contacts.id NOT IN (?)', Erp::Contacts::Contact.get_main_contact.id)
              .where(is_customer: true)
          end
          
          @customers = @customers.search(params)
          
          #filters // only customers with records
          if params.to_unsafe_hash["filters"].present?
            params.to_unsafe_hash["filters"].each do |ft|
              ft[1].each do |cond|
                if cond[1]["name"] == 'in_period_active'
                  @customers = @customers.get_customer_commission_payment_chasing_contacts
                  #(
                  #  from_date: @from,
                  #  to_date: @to
                  #)
                end
              end
            end
          end
          
          @customers = @customers.paginate(:page => params[:page], :per_page => 20)
        end

        def customer_commission_details
        end
        
        def customer_commission_sales_orders_list
          @orders = Erp::Contacts::Contact.find(params[:customer_id])
            .sales_orders
            .payment_for_contact_orders(params.to_unsafe_hash)
          
          @full_orders = @orders
          
          @orders = @orders.order('erp_orders_orders.order_date DESC, erp_orders_orders.created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end
        
        def customer_commission_payment_records_list
          more_filter = params.to_unsafe_hash[:more_filter]
          if more_filter[:period].present?
            @from_date = Erp::Periods::Period.find(more_filter[:period]).from_date.beginning_of_day
            @to_date = Erp::Periods::Period.find(more_filter[:period]).to_date.end_of_day
          else
            @from_date = (more_filter.present? and more_filter[:from_date].present?) ? more_filter[:from_date].to_date : nil
            @to_date = (more_filter.present? and more_filter[:to_date].present?) ? more_filter[:to_date].to_date : nil
          end
          
          @payment_records = Erp::Payments::PaymentRecord.all_done
            .where(customer_id: params[:customer_id])
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION).id)
            
          if @from_date.present?
            @payment_records = @payment_records.where('payment_date >= ?', @from_date.beginning_of_day)
          end
    
          if @to_date.present?
            @payment_records = @payment_records.where('payment_date <= ?', @to_date.end_of_day)
          end
            
          @full_payment_records = @payment_records
          
          @payment_records = @payment_records.order('payment_date DESC, created_at DESC')
            .paginate(:page => params[:page], :per_page => 10)
        end

        # Export excel file
        def list_xlsx
          @payment_records = PaymentRecord.order(:payment_date).search(params)
          @accounts = Account.where(id: @payment_records.select(:account_id))

          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end

          # Recieved total
          @total_received = @accounts.received(from_date: @from, to_date: @to)

          # Paid total
          @total_paid = @accounts.paid(from_date: @from, to_date: @to)

          # Begin of period amount
          @begin_period_amount = @accounts.account_balance(to_date: (@from - 1.day))

          # End of period amount
          @end_period_amount = @accounts.account_balance(to_date: @to)

          @payment_records = @payment_records

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Tong hop thu chi.xlsx'"
            }
          end
        end

        def pay_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end

          @payments = Erp::Payments::PaymentRecord.all_done.all_paid(from_date: @from, to_date: @to)

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Nhat ky chi tien.xlsx'"
            }
          end
        end

        def receive_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end

          @receipts = Erp::Payments::PaymentRecord.all_done.all_received(from_date: @from, to_date: @to)

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Nhat ky thu tien.xlsx'"
            }
          end
        end
        
        def liabilities_tracking_periods_list
          @customer = Erp::Contacts::Contact.where(id: params[:customer_id]).first
          
          if params[:period].present?
            period = Erp::Periods::Period.find(params[:period])
            params[:from_date] = period.from_date
            params[:to_date] = period.to_date
          end
          
          # periods
          current_month = Time.now.month
          current_year = Time.now.year
          @times = []
          @times << {
            name: "Tháng #{current_month}/#{current_year}",
            from_date: Time.now.beginning_of_month.beginning_of_day,
            to_date: Time.now.end_of_month.end_of_day,
            period: Erp::Periods::Period.find_month_by_times(from_date: Time.now.beginning_of_month.beginning_of_day, to_date: Time.now.end_of_month.end_of_day)
          }
          
          month = current_month - 1
          while month > 0 do
            @times << {
              name: "Tháng #{month}/#{current_year}",
              from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day,
              to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day,
              period: Erp::Periods::Period.find_month_by_times(from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day, to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day)
            }
            month -= 1
          end
          
          @times << {name: "Năm #{current_year-1}", from_date: (Time.now - 1.year).beginning_of_year.beginning_of_day, to_date: (Time.now - 1.year).end_of_year.end_of_day}
          @times = @times.reverse!
        end
        
        def supplier_liabilities_tracking_periods_list
          @supplier = Erp::Contacts::Contact.where(id: params[:supplier_id]).first
          
          if params[:period].present?
            period = Erp::Periods::Period.find(params[:period])
            params[:from_date] = period.from_date
            params[:to_date] = period.to_date
          end
          
          # periods
          current_month = Time.now.month
          current_year = Time.now.year
          @times = []
          @times << {
            name: "Tháng #{current_month}/#{current_year}",
            from_date: Time.now.beginning_of_month.beginning_of_day,
            to_date: Time.now.end_of_month.end_of_day,
            period: Erp::Periods::Period.find_month_by_times(from_date: Time.now.beginning_of_month.beginning_of_day, to_date: Time.now.end_of_month.end_of_day)
          }
          
          month = current_month - 1
          while month > 0 do
            @times << {
              name: "Tháng #{month}/#{current_year}",
              from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day,
              to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day,
              period: Erp::Periods::Period.find_month_by_times(from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day, to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day)
            }
            month -= 1
          end
          
          @times << {name: "Năm #{current_year-1}", from_date: (Time.now - 1.year).beginning_of_year.beginning_of_day, to_date: (Time.now - 1.year).end_of_year.end_of_day}
          @times = @times.reverse!
        end
        
        def customer_commission_periods_list
          @customer = Erp::Contacts::Contact.where(id: params[:customer_id]).first
          
          if params[:period].present?
            period = Erp::Periods::Period.find(params[:period])
            params[:from_date] = period.from_date
            params[:to_date] = period.to_date
          end
          
          # periods
          current_month = Time.now.month
          current_year = Time.now.year
          @times = []
          @times << {
            name: "Tháng #{current_month}/#{current_year}",
            from_date: Time.now.beginning_of_month.beginning_of_day,
            to_date: Time.now.end_of_month.end_of_day,
            period: Erp::Periods::Period.find_month_by_times(from_date: Time.now.beginning_of_month.beginning_of_day, to_date: Time.now.end_of_month.end_of_day)
          }
          
          month = current_month - 1
          while month > 0 do
            @times << {
              name: "Tháng #{month}/#{current_year}",
              from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day,
              to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day,
              period: Erp::Periods::Period.find_month_by_times(from_date: "#{current_year}-#{month}-01".to_date.beginning_of_month.beginning_of_day, to_date: "#{current_year}-#{month}-01".to_date.end_of_month.end_of_day)
            }
            month -= 1
          end
          
          @times << {name: "Năm #{current_year-1}", from_date: (Time.now - 1.year).beginning_of_year.beginning_of_day, to_date: (Time.now - 1.year).end_of_year.end_of_day}
          @times = @times.reverse!
        end
        
        # download zip files
        def export_pdf_files
          records = PaymentRecord.search(params)

          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
            @period_name = Erp::Periods::Period.find(glb[:period]).name
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
            @period_name = nil
          end

          @payment_records = records
          
          # create files
          tmp_path = "tmp/#{Time.now.to_i}/"
          @payment_records.each do |pr|
            create_pdf_file(pr, tmp_path)
          end
          
          # zip files
          temp = Tempfile.new 'phieu_thu_chi.zip'
          Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
            Dir.foreach(tmp_path) do |file|
              next if file == '.' or file == '..'
              # do work on real items
              zipfile.add file, tmp_path + file
            end
          end
          
          send_file temp.path, type: "application/zip", x_sendfile: true,
            disposition: "attachment", filename: "phieu_thu_chi.zip"
        end
        
        def create_pdf_file(payment_record, tmp_path)
          tmp_file_name = "#{payment_record.code}-#{current_user.id}.pdf"
          tmp_file = "#{tmp_path}#{tmp_file_name}"
          Dir.mkdir(tmp_path) unless File.exists?(tmp_path)
          
          @payment_record = payment_record
          
          pdf = render_to_string pdf: "#{payment_record.code}",
            title: "#{payment_record.code}",
            layout: 'erp/backend/pdf',
            page_size: 'A5',
            orientation: 'Landscape',
            template: 'erp/payments/backend/payment_records/pdf',
            margin: {
              top: 10,
              bottom: 7,
              left: 7,
              right: 7
            }
            
          File.open(tmp_file, "wb") { |file| file.write pdf }
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
            params.fetch(:payment_record, {}).permit(:address, :payment_method, :debit_account_id, :credit_account_id, :code, :amount, :payment_date, :pay_receive, :description, :status, :order_id, :delivery_id,
                                                     :accountant_id, :customer_id, :supplier_id, :employee_id, :account_id, :payment_type_id, :origin_doc, :period_id)
          end
      end
    end
  end
end
