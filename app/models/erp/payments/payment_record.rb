module Erp::Payments
  class PaymentRecord < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :accountant, class_name: "Erp::User"
    belongs_to :employee, class_name: "Erp::User", optional: true
    belongs_to :account, class_name: "Erp::Payments::Account", optional: true
    belongs_to :payment_type, class_name: "Erp::Payments::PaymentType"

    belongs_to :debit_account, class_name: "Erp::Payments::Account"
    belongs_to :credit_account, class_name: "Erp::Payments::Account"

    PAYMENT_METHOD_CASH = 'cash'
    PAYMENT_METHOD_ACCOUNT = 'account'

    if Erp::Core.available?("contacts")
      belongs_to :customer, class_name: "Erp::Contacts::Contact", optional: true
      belongs_to :supplier, class_name: "Erp::Contacts::Contact", optional: true

      def customer_name
        customer.present? ? customer.contact_name : ''
      end

      def supplier_name
        supplier.present? ? supplier.contact_name : ''
      end

      def customer_address
        customer.present? ? customer.address : ''
      end

      def supplier_address
        supplier.present? ? supplier.address : ''
      end

      def customer_phone
        customer.present? ? customer.phone : ''
      end

      def supplier_phone
        supplier.present? ? supplier.phone : ''
      end
    end

    def creator_name
      creator.name
    end

    def payment_type_code
      payment_type.present? ? payment_type.code : ''
    end

    def payment_type_name
      payment_type.present? ? payment_type.name : ''
    end

    if Erp::Core.available?("orders")
      belongs_to :order, class_name: "Erp::Orders::Order", optional: true
    end

    if Erp::Core.available?("qdeliveries")
      belongs_to :delivery, class_name: "Erp::Qdeliveries::Delivery", optional: true

      after_save :delivery_update_cache_payment_status
      after_destroy :delivery_update_cache_payment_status

      def delivery_code
        delivery.present? ? delivery.code : ''
      end

      def delivery_update_cache_payment_status
        if delivery.present?
          delivery.update_cache_payment_status
        end
      end
    end

    validates :code, uniqueness: true
    validates :payment_date, :amount, :accountant_id, :presence => true

    after_save :order_update_cache_payment_status
    after_destroy :order_update_cache_payment_status

    # class const
    TYPE_RECEIVE = 'receive'
    TYPE_PAY = 'pay'

    STATUS_DELETED = 'deleted'
    STATUS_DONE = 'done'

    def amount=(new_price)
      self[:amount] = new_price.to_s.gsub(/\,/, '')
    end

    # get type method options
    def self.get_type_record_options()
      [
        {text: I18n.t('.receive'), value: Erp::Payments::PaymentRecord::TYPE_RECEIVE},
        {text: I18n.t('.pay'), value: Erp::Payments::PaymentRecord::TYPE_PAY}
      ]
    end

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end

      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      # global filter
      global_filter = params[:global_filter]

      if global_filter.present?

				# filter by order from date
				if global_filter[:from_date].present?
					query = query.where('payment_date >= ?', global_filter[:from_date].to_date.beginning_of_day)
				end

				# filter by order to date
				if global_filter[:to_date].present?
					query = query.where('payment_date <= ?', global_filter[:to_date].to_date.end_of_day)
				end

				# filter by order warehouse
				if global_filter[:period].present?
					query = query.where('payment_date >= ? AND payment_date <= ?',
                              Erp::Periods::Period.find(global_filter[:period]).from_date.beginning_of_day,
                              Erp::Periods::Period.find(global_filter[:period]).to_date.end_of_day)
				end

				# filter by customer
				if global_filter[:customer].present?
					query = query.where(customer_id: global_filter[:customer])
				end

				# filter by supplier
				if global_filter[:supplier].present?
					query = query.where(supplier_id: global_filter[:supplier])
				end

				# filter by employee
				if global_filter[:employee].present?
					query = query.where(employee_id: global_filter[:employee])
				end

				# filter by employee
				if global_filter[:payment_type].present?
					query = query.where(payment_type_id: global_filter[:payment_type])
				end

				# filter by debit account
				if global_filter[:debit_account].present?
					query = query.where(debit_account_id: global_filter[:debit_account])
				end

				# filter by employee
				if global_filter[:credit_account].present?
					query = query.where(credit_account_id: global_filter[:credit_account])
				end

				# filter by payment method
				if global_filter[:payment_method].present?
					query = query.where(payment_method: global_filter[:payment_method])
				end

			end
      # end// global filter

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end

    # Display name
    def accountant_name
      accountant.present? ? accountant.name : ''
    end

    def employee_name
      employee.present? ? employee.name : ''
    end

    def account_name
      account.present? ? account.name : ''
    end

    def credit_account_name
      credit_account.present? ? credit_account.display_name : ''
    end

    def debit_account_name
      debit_account.present? ? debit_account.display_name : ''
    end

    def credit_account_code
      credit_account.present? ? credit_account.code : ''
    end

    def debit_account_code
      debit_account.present? ? debit_account.code : ''
    end

    def get_contact
      if [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id,
        Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id].include?(payment_type_id)
        if customer.present?
          query = customer
        end
      end
      if [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_PURCHASE_ORDER).id,
        Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER).id].include?(payment_type_id)
        if supplier.present?
          query = supplier
        end
      end
      if [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_PRODUCT_RETURN).id].include?(payment_type_id)
        if supplier.present?
          query = supplier
        else
          query = customer
        end
      end
      if [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_COMMISSION).id].include?(payment_type_id)
        if employee.present?
          query = employee
        end
      end
      if [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION).id].include?(payment_type_id)
        if customer.present?
          query = customer
        end
      end
      return query
    end

    def get_contact_name
      if customer.present?
        return customer.name
      end
      if supplier.present?
        return supplier.name
      end
      if employee.present?
        employee.name
      end
    end

    # Generate code
    before_validation :generate_code
    def generate_code
			if !code.present?
				if is_receipt_voucher?
					query = Erp::Payments::PaymentRecord.where(pay_receive: Erp::Payments::PaymentRecord::TYPE_RECEIVE)
				elsif is_payment_voucher?
					query = Erp::Payments::PaymentRecord.where(pay_receive: Erp::Payments::PaymentRecord::TYPE_PAY)
				end

				str = (is_receipt_voucher? ? 'PT' : 'PC')
				num = query.where('payment_date >= ? AND payment_date <= ?', self.payment_date.beginning_of_month, self.payment_date.end_of_month).count + 1

				self.code = str + payment_date.strftime("%m") + payment_date.strftime("%Y").last(2) + "-" + num.to_s.rjust(3, '0')
			end
		end

    # DISPLAY ORDER INFORMATION
    # order date
    def order_date(params={})
      if order.present?
        order.order_date
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).order_date
      end
    end

    # order expiration date
    def payment_deadline(params)
      if order.present?
        order.get_payment_deadline
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).get_payment_deadline
      end
    end

    def order_code(params={})
      if order.present?
        order.code
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).code
      end
    end

    # order customer name
    def order_customer(params={})
      if order.present?
        order.customer_name
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).customer_name
      end
    end

    # order paid amount
    def order_paid_amount(params)
      if order.present?
        order.paid_amount
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).paid_amount
      end
    end

    # order total
    def order_total(params)
      if order.present?
        order.total
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).total
      end
    end

    # order remain amount
    def order_remain_amount(params)
      if order.present?
        order.remain_amount
      elsif params[:order_id].present?
        Erp::Orders::Order.find(params[:order_id]).remain_amount
      end
    end

    def order_update_cache_payment_status
			if order.present?
				order.update_cache_payment_status
			end
		end

    def set_done
      update_columns(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end

    def set_deleted
      update_columns(status: Erp::Payments::PaymentRecord::STATUS_DELETED)
    end

    def self.confirm_all
      update_all(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end

    def self.set_deleted_all
      update_all(status: Erp::Payments::PaymentRecord::STATUS_DELETED)
    end

    def is_done?
      return self.status == Erp::Payments::PaymentRecord::STATUS_DONE
    end

    def is_deleted?
      return self.status == Erp::Payments::PaymentRecord::STATUS_DELETED
    end

    def is_receipt_voucher?
      return self.pay_receive == Erp::Payments::PaymentRecord::TYPE_RECEIVE
    end

    def is_payment_voucher?
      return self.pay_receive == Erp::Payments::PaymentRecord::TYPE_PAY
    end

    # ############################# START - REVIEWING ################################
    def self.get_order_payment_records(params)
      self.where(order_id: params[:order_id])
    end

    # Get all done payment_records
    def self.all_done
      self.where(status: Erp::Payments::PaymentRecord::STATUS_DONE)
    end

    # Get receive payment record
    def self.all_received(params={})
      query = self.where(pay_receive: Erp::Payments::PaymentRecord::TYPE_RECEIVE)

      if params[:from_date].present?
        query = query.where("payment_date >= ?", params[:from_date].beginning_of_day)
      end

      if params[:to_date].present?
        query = query.where("payment_date <= ?", params[:to_date].end_of_day)
      end

      if params[:period].present?
        query = query.where("payment_date >= ? AND payment_date <= ?",
                            Erp::Periods::Period.find(params[:period]).from_date.beginning_of_day,
                            Erp::Periods::Period.find(params[:period]).to_date.end_of_day)
      end

      return query
    end

    # Get pay payment record
    def self.all_paid(params={})
      query = self.where(pay_receive: Erp::Payments::PaymentRecord::TYPE_PAY)

      if params[:from_date].present?
        query = query.where("payment_date >= ?", params[:from_date].beginning_of_day)
      end

      if params[:to_date].present?
        query = query.where("payment_date <= ?", params[:to_date].end_of_day)
      end

      if params[:period].present?
        query = query.where("payment_date >= ? AND payment_date <= ?",
                            Erp::Periods::Period.find(params[:period]).from_date.beginning_of_day,
                            Erp::Periods::Period.find(params[:period]).to_date.end_of_day)
      end

      return query
    end

    # get total recieved amount
    def self.received_amount(params={})
      self.all_done.all_received(params).sum(:amount)
    end

    # get total paid amount
    def self.paid_amount(params={})
      self.all_done.all_paid(params).sum(:amount)
    end

    # get remain amount (beginning/end) of period
    def self.remain_amount(params={})
      self.received_amount(params) - self.paid_amount(params)
    end
    # ############################# END - REVIEWING ################################

    # revenue by period
    def self.revenue_by_period(params={})
      total = 0.0

      # Tong tien thu duoc tu khach hang
      total = total + self.all_done.all_received(params)
                          .where(payment_type_id: [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER),
                                                   Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)])
                          .sum(:amount)

      # Tong tien tra lai cho khach hang
      total = total - self.all_done.all_paid(params)
                          .where(payment_type_id: [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER),
                                                   Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)])
                          .sum(:amount)
      return total
    end

    # customer commission amount
    def customer_commission_percent
      return self.customer.present? ? self.customer.commission_percent : 0
    end

    def commission_amount
      return self.amount*(self.customer_commission_percent.to_f/100)
    end

    # check if new account
    def new_customer?
      return false if self.customer.nil?

      orders = Erp::Orders::Order.where(status: Erp::Orders::Order::STATUS_CONFIRMED)
        .where(customer_id: self.customer_id)
        .where('order_date <= ?', (self.payment_date - 1.month).end_of_month)

      return orders.count == 0
    end

    # new account commission
    def new_account_commission_amount
      return (self.new_customer? ? self.customer.new_account_commission_amount.to_f : 0)
    end
  end
end
