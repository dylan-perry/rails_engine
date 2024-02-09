class Api::V1::Items::SearchController < ApplicationController
  before_action :validate_params, only: [:find]

    def find
        if params.key?(:name) && (!params.key?(:min_price) && !params.key?(:max_price))
            item = Item.where("name ILIKE ?", "%#{params[:name]}%").order(name: :asc).first
        elsif params.key?(:min_price) && (!params.key?(:name) && !params.key?(:max_price))
            item = Item.where("unit_price >= ?", params[:min_price]).order(name: :asc).first
        elsif params.key?(:max_price) && (!params.key?(:name) && !params.key?(:min_price))
            item = Item.where("unit_price <= ?", params[:max_price]).order(name: :asc).first
        elsif (params.key?(:min_price) && params.key?(:max_price)) && !params.key?(:name)
            item = Item.where("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price]).order(name: :asc).first
        end

        if item == nil
          render json: { :data=> {
            errors: [{status: "200", title: "Item not found"}]}}
        else 
          render json: ItemSerializer.new(item)
        end
    end

private

  def validate_params

    # param existence and contradiction validations

    # if name, min_price, max_price are all missing, error out
    if params[:name].nil? && params[:min_price].nil? && params[:max_price].nil?
        raise ActionController::BadRequest, 'Must have either name or price range'
    # if name AND min_price OR max_price are present, error out 
    elsif !params[:name].nil? && (!params[:min_price].nil? || !params[:max_price].nil?)
        raise ActionController::BadRequest, 'Cannot have name and price range at the same time'
    end

    # Must write sad paths for two negative individual min and max params, and negative range when min is subtracted from max

    # Negative numbers validation (only runs if params were passed in)

    # if min_price was passed, and is negative, error out
    if !params[:min_price].nil? && params[:min_price].to_f.negative?
        raise ActionController::BadRequest, 'Minimum price cannot be negative'
    end
    
    # if max_price was passed, and is negative, error out
    if !params[:max_price].nil? && params[:max_price].to_f.negative?
        raise ActionController::BadRequest, 'Maximum price cannot be negative'
    end

    # if min_price AND max_price were passed, and max_price minus min_price is negative, error out
    if (!params[:min_price].nil? && !params[:max_price].nil?) && (params[:max_price].to_f - params[:min_price].to_f).negative?
        raise ActionController::BadRequest, 'Price range cannot be negative'
    end
  end
end
