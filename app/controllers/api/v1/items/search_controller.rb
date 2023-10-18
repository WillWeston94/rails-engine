class Api::V1::Items::SearchController < ApplicationController
  def find

    if params[:min_price].present? && params[:max_price].present?
      render json: { errors: 'Cannot send both min_price and max_price together' }, status: 400
      return
    end

    if params[:min_price].present? && params[:name].present?
      render json: { errors: 'Cannot send both name and min_price together' }, status: 400
      return
    end

    if params[:max_price].present? && params[:name].present?
      render json: { errors: 'Cannot send both name and max_price together' }, status: 400
      return
    end
    
    if params[:min_price].present? && params[:min_price].to_f < 0
      render json: { errors: 'min_price must be greater than or equal to 0' }, status: 400
      return
    end

    if params[:max_price].present? && params[:max_price].to_f < 0
      render json: { errors: 'max_price must be greater than or equal to 0' }, status: 400
      return
    end

    if params[:min_price].present?
      item = Item.where('unit_price >= ?', params[:min_price].to_f).order(:name).first
    elsif params[:max_price].present?
      item = Item.where('unit_price <= ?', params[:max_price].to_f).order(:name).last
    elsif params[:name].present?
      item = Item.where('LOWER(name) LIKE ?', "%#{params[:name].downcase}%").order(:name).first
    else
      render json: { errors: 'Parameters not met' }, status: 400
      return
    end

    if item
      render json: ItemSerializer.new(item)
    else
      render json: { data: {} }
    end
  end
end