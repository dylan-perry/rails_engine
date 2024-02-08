class Api::V1::Items::SearchController < ApplicationController
    def find
        require 'pry'; binding.pry
        render json: ItemSerializer.new(Item.find_by(params[:name]).order(name: :desc).first)
    end
end
