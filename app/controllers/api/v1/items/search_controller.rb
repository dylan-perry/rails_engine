class Api::V1::Items::SearchController < ApplicationController
  before_action :validate_params, only: [:find]
    def find
        # require 'pry'; binding.pry
        # params[:name] == nil && (params[:min_price] && params[:max_price]) == nil
        # if params[:min_price] || params[:max_price]

        item = Item.where("name ILIKE ?", "%#{params[:name]}%").order(name: :asc).first
        if item == nil
          raise ActionController::BadRequest, 'Item not found'
        else 
          render json: ItemSerializer.new(item)
        end
    end

private
  def validate_params
    has_name = params.key?(:name)
    has_price_range = params.key?(:min_price) || params.key?(:max_price)

    if has_name && has_price_range
      raise ActionController::BadRequest, 'Cannot have name and price range at the same time'
    elsif !has_name && !has_price_range
      raise ActionController::BadRequest, 'Must have either name or price range'
    end
  end
end
