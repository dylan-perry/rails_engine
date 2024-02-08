class Api::V1::ItemsController < ApplicationController

  def index
      render json: ItemSerializer.new(Item.all)
  end

  def show
      render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    # Tries to find a merchant record, if record is found it returns true and if not
    # an ActiveRecord::RecordNotFound exception is rescued
    return unless check_merchant_exists(item_params[:merchant_id])

    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: :created
    else
      error_message = ErrorMessage.new(item.errors.full_messages.join(', '), 422)
      render json: ErrorSerializer.new(error_message).serialize_json, status: :unprocessable_entity
    end
  end

  def destroy
    # require 'pry';binding.pry
    item = Item.find(params[:id].to_i)
    render json: item.destroy
    # render json: BookSerializer.new(item)
  end

private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id )
  end

  def check_merchant_exists(merchant_id)
    Merchant.find(merchant_id)
  end
end