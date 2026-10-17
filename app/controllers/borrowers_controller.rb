class BorrowersController < ApplicationController
  include Paginatable
  before_action :set_borrower, only: %i[ show edit update destroy ]

  def index
    @borrowers = paginate(Current.user.borrowers.alphabetical)
  end

  def show
    @loans = paginate(@borrower.loans.includes(:item).recent_first)
  end

  def new
    @borrower = Current.user.borrowers.new
  end

  def create
    @borrower = Current.user.borrowers.new(borrower_params)
    if @borrower.save
      redirect_to @borrower, notice: "Added to your people.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @borrower.update(borrower_params)
      redirect_to @borrower, notice: "Person updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @borrower.destroy
      redirect_to borrowers_path, notice: "Person deleted.", status: :see_other
    else
      redirect_to @borrower, alert: "This person has lending history, so they cannot be deleted.", status: :see_other
    end
  end

  private
    def set_borrower
      @borrower = Current.user.borrowers.find(params[:id])
    end

    def borrower_params
      params.expect(borrower: [ :name, :email, :notes ])
    end
end
