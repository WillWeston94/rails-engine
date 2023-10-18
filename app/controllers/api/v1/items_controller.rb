class Api::V1::ItemsController < ApplicationController
  before_action :find_item, only: [:show, :update, :destroy]

  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(@item)
  end
  
  def create
    if params[:merchant_id]
      merchant = Merchant.find(params[:merchant_id])
      unless merchant
        render json: { error: "Merchant not found" }, status: :not_found
        return
      end
    end

    item = Item.create(item_params)
  
    if item.save
      render json: ItemSerializer.new(item), status: :created
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def update
    if params[:merchant_id]
      merchant = Merchant.find(params[:merchant_id])
      unless merchant
        render json: { error: "Merchant not found" }, status: :not_found
        return
      end
    end
    if @item.update(item_params)
      render json: ItemSerializer.new(@item)
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def find_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Item not found" }, status: :not_found
  end

end 
