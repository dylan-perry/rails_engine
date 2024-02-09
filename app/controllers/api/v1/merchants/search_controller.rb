class Api::V1::Merchants::SearchController < ApplicationController
  def find_all
    merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%").order(name: :asc)

    if merchants == []
      render json: { :data=> []}
    else 
      render json: MerchantSerializer.new(merchants)
    end
  end
end