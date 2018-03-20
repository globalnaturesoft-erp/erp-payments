module Erp::Payments
  class Account < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    validates :name, presence: true

    # class const
    STATUS_ACTIVE = 'active'
    STATUS_DELETED = 'deleted'
    
    PAYMENT_METHOD_CASH = 'cash'
    PAYMENT_METHOD_ACCOUNT = 'account'

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []
      show_archived = false

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            # in case filter is show archived
            if cond[1]["name"] == 'show_archived'
              show_archived = true
            else
              or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
            end
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end

      # show archived items condition - default: false
      show_archived = false

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            # in case filter is show archived
            if cond[1]["name"] == 'show_archived'
              # show archived items
              show_archived = true
            else
              or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
            end
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

      # join with users table for search creator
      query = query.joins(:creator)

      # showing archived items if show_archived is not true
      query = query.where(archived: false) if show_archived == false

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      # global filter
      global_filter = params[:global_filter]

      if global_filter.present?

				# filter by self
				if global_filter[:account].present?
					query = query.where(id: global_filter[:account])
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

    # data for dataselect ajax
    def self.dataselect(keyword='')
      query = self.where(status: Erp::Payments::Account::STATUS_ACTIVE)

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ? OR LOWER(code) LIKE ?', "%#{keyword}%", "%#{keyword}%")
      end

      query = query.limit(20).order(:code).map{|debt| {value: debt.id, text: debt.display_name} }
    end

    def archive
			update_attributes(archived: true)
		end

    def unarchive
			update_attributes(archived: false)
		end

    def self.archive_all
			update_all(archived: true)
		end

    def self.unarchive_all
			update_all(archived: false)
		end

    def set_active
      update_attributes(status: Erp::Payments::Account::STATUS_ACTIVE)
    end

    def set_deleted
      update_attributes(status: Erp::Payments::Account::STATUS_DELETED)
    end

    # Check is-active? / is-deleted?
    def is_active?
      return self.status == Erp::Payments::Account::STATUS_ACTIVE
    end

    def is_deleted?
      return self.status == Erp::Payments::Account::STATUS_DELETED
    end

    # --------- Report Functions - Start ---------
    # Danh sach phieu thu/chi lien quan den Account
    def payment_records(params={})
      query = Erp::Payments::PaymentRecord.all_done.where(account_id: self.id)

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
    
    # So tien thu vao tai khoan
    def received(params={})
      return Erp::Payments::PaymentRecord.all_done.all_received(params).where(account_id: self.id).sum(:amount)
    end

    # So tien chi ra tu tai khoan
    def paid(params={})
      return Erp::Payments::PaymentRecord.all_done.all_paid(params).where(account_id: self.id).sum(:amount)
    end

    # Tong tien thu vao
    def self.received(params={})
      return Erp::Payments::PaymentRecord.all_done.received_amount(params)
    end

    # Tong tien chi ra
    def self.paid(params={})
      return Erp::Payments::PaymentRecord.all_done.paid_amount(params)
    end

    # So du tai khoan dau ky / cuoi ky
    def account_balance(params={})
      return self.received(params) - self.paid(params)
    end

    def self.account_balance(params={})
      return self.received(params) - self.paid(params)
    end
    # --------- Report Functions - End ---------

    def display_name
      "#{name}"
    end
  end
end
