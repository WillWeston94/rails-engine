class Api::V1::Merchants::SearchController < ApplicationController
  def find_all
    if params[:name].blank?
      render json: { error: "Name cannot be blank" }, status: :bad_request
      return
    end

    if params[:name].present?
      merchants = Merchant.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name)
      render json: MerchantSerializer.new(merchants)
    else
      render json: { data: {} }
    end
  end
end