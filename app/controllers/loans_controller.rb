class LoansController < ApplicationController
  include Paginatable
  before_action :set_loan, only: %i[ show edit update ]

  def index
    @status = params[:status].in?(%w[outstanding overdue returned all]) ? params[:status] : "outstanding"
    @query = params[:q].to_s.strip.first(100)
    records = Current.user.loans
    @counts = { outstanding: records.outstanding.count, overdue: records.overdue.count, returned: records.returned.count }
    filtered = case @status
    when "overdue" then records.overdue
    when "returned" then records.returned
    when "all" then records
    else records.outstanding
    end
    @loans = paginate(filtered.search(@query).includes(:item, :borrower).order(due_on: :asc, id: :desc))
  end

  def show
  end

  def new
    @loan = Current.user.loans.new(lent_on: Date.current, due_on: Date.current + 7)
    @loan.item = Current.user.items.find(params[:item_id]) if params[:item_id].present?
    @loan.borrower = Current.user.borrowers.find(params[:borrower_id]) if params[:borrower_id].present?
    prepare_options
  end

  def create
    @loan = Current.user.loans.new
    assign_loan_attributes
    if @loan.save
      redirect_to @loan, notice: "A little handoff, remembered.", status: :see_other
    else
      render_form :new
    end
  rescue ActiveRecord::RecordNotUnique
    @loan.errors.add(:item, "is already out on loan")
    render_form :new
  end

  def edit
    prepare_options
  end

  def update
    assign_loan_attributes
    if @loan.save
      redirect_to @loan, notice: "Loan updated.", status: :see_other
    else
      render_form :edit
    end
  rescue ActiveRecord::RecordNotUnique
    @loan.errors.add(:item, "is already out on loan")
    render_form :edit
  end

  private
    def set_loan
      @loan = Current.user.loans.includes(:item, :borrower).find(params[:id])
    end

    def assign_loan_attributes
      attributes = params.expect(loan: [ :item_id, :borrower_id, :lent_on, :due_on, :notes ])
      @loan.assign_attributes(attributes.except(:item_id, :borrower_id))
      if attributes.key?(:item_id)
        @loan.item = Current.user.items.find(attributes[:item_id]) if attributes[:item_id].present?
        @loan.item = nil if attributes[:item_id].blank?
      end
      if attributes.key?(:borrower_id)
        @loan.borrower = Current.user.borrowers.find(attributes[:borrower_id]) if attributes[:borrower_id].present?
        @loan.borrower = nil if attributes[:borrower_id].blank?
      end
    end

    def prepare_options
      available = Current.user.items.available
      available = available.or(Current.user.items.where(id: @loan.item_id)) if @loan.item_id
      @items = available.alphabetical
      @borrowers = Current.user.borrowers.alphabetical
    end

    def render_form(template)
      prepare_options
      render template, status: :unprocessable_entity
    end
end
