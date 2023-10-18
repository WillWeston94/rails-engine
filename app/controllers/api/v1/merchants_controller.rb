class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end
        
  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def create
    merchant = Merchant.create(merchant_params)

    if merchant.save
      render json: merchant, status: :created
    else
      render json: merchant.errors, status: :unprocessable_entity
    end
  end

  def update
    render json: Merchant.update(params[:id], merchant_params)
  end

  def destroy
    Merchant.find(params[:id]).destroy!

    head :no_content
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end