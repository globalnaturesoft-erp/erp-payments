module Erp::Payments
  class AccountingAccount < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    validates :code, :name, presence: true
    
    # class const
    STATUS_ACTIVE = 'active'
    STATUS_DELETED = 'deleted'
    
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

      # join with users table for search creator
      query = query.joins(:creator)

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

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
      query = self.all

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ? OR LOWER(code) LIKE ?', "%#{keyword}%", "%#{keyword}%")
      end

      query = query.limit(20).order(:code).map{|debt| {value: debt.id, text: debt.display_name} }
    end
    
    # Set status active/deleted
    def set_active
      update_attributes(status: Erp::Payments::AccountingAccount::STATUS_ACTIVE)
    end

    def set_deleted
      update_attributes(status: Erp::Payments::AccountingAccount::STATUS_DELETED)
    end

    # Check is-active? / is-deleted?
    def is_active?
      return self.status == Erp::Payments::AccountingAccount::STATUS_ACTIVE
    end

    def is_deleted?
      return self.status == Erp::Payments::AccountingAccount::STATUS_DELETED
    end
    
    def display_name
      "#{code}-#{name}"
    end
  end
end
