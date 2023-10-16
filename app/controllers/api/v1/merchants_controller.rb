class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: merchants
  end
        
  def show
    merchant = Merchant.find(params[:id])
    render json: merchant
  end

  def new
  end

  def create
    merchant = Merchant.create(name: params[:name])

    if merchant.save
      render json: Merchant.new(merchant), status: :created
    else
      render json: { errors: merchant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
  end

  def destroy
    Merchant.find(params[:id]).destroy!

    head :no_content
  end
end