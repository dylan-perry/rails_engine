class Api::V1::Items::SearchController < ApplicationController
    def find
        # require 'pry'; binding.pry
        render json: ItemSerializer.new(Item.where("name ILIKE ?", "%#{params[:name]}%").order(name: :asc).first)
        # Item.where("name LIKE ?", "%Choco%")c
    end
end
