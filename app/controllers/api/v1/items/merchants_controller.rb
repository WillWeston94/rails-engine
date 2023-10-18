class Api::V1::Items::MerchantsController < ApplicationController
  def index
    begin
    item = Item.find(params[:item_id])
    merchant = Merchant.find(item.merchant_id)

    render json: MerchantSerializer.new(merchant)
    rescue ActiveRecord::RecordNotFound
    render json: { error: "Item not found" }, status: :not_found
    end
  end

  def show
    item = Item.find(params[:id])
    merchant = Merchant.find(item.merchant_id)

    if merchant 
    render json: MerchantSerializer.new(merchant)
    else
    render json: { error: "Item not found" }, status: :not_found
    end
  end
end