class ItemsController < ApplicationController
  include Paginatable
  before_action :set_item, only: %i[ show edit update destroy ]

  def index
    @items = paginate(Current.user.items.alphabetical.includes(outstanding_loan: :borrower))
  end

  def show
    @loans = paginate(@item.loans.includes(:borrower).recent_first)
  end

  def new
    @item = Current.user.items.new
  end

  def create
    @item = Current.user.items.new(item_params)
    if @item.save
      redirect_to @item, notice: "Added to your things.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @item.destroy
      redirect_to items_path, notice: "Item deleted.", status: :see_other
    else
      redirect_to @item, alert: "This item has lending history, so it cannot be deleted.", status: :see_other
    end
  end

  private
    def set_item
      @item = Current.user.items.find(params[:id])
    end

    def item_params
      params.expect(item: [ :name, :description ])
    end
end
