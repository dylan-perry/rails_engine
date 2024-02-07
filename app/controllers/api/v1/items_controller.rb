class Api::V1::ItemsController < ApplicationController

    def show
        render json: ItemSerializer.new(Item.find(params[:id]))
    end
end