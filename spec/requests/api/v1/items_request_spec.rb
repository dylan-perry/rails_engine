require 'rails_helper'

describe "Items API" do
    describe "happy path" do
        it "sends a list of items (when item count > 1)" do
            create_list(:item, 3)
    
            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items[:data].count).to eq(3)
            expect(items[:data]).to be_a(Array)
    
            items[:data].each do |item|
                expect(item[:attributes]).to have_key(:name) 
                expect(item[:attributes]).to have_key(:description)    
                expect(item[:attributes]).to have_key(:unit_price)
            end
        end

        it "sends a list of items (when item count == 1)" do
            create_list(:item, 1)

            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items[:data].count).to eq(1)
            expect(items[:data]).to be_a(Array)
    
            items[:data].each do |item|
                expect(item[:attributes]).to have_key(:name) 
                expect(item[:attributes]).to have_key(:description)    
                expect(item[:attributes]).to have_key(:unit_price)
            end
        end

        # US 5
        it "can create a new item" do
          merchant = create(:merchant, id: 1)

          item_params = ({
                          name: 'Ben & Jerrys',
                          description: 'Ice Cream',
                          unit_price: 4.99,
                          merchant_id: 1
                        })
          headers = {"CONTENT_TYPE" => "application/json"}
          
          # include header to make sure params are passed as JSON rather than as plain text
          post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
          created_item = Item.last
        
          expect(response).to be_successful

          expect(created_item.name).to eq(item_params[:name])
          expect(created_item.name).to be_a(String)

          expect(created_item.description).to eq(item_params[:description])
          expect(created_item.description).to be_a(String)

          expect(created_item.unit_price).to eq(item_params[:unit_price])
          expect(created_item.unit_price).to be_a(Float)

          expect(created_item.merchant_id).to eq(item_params[:merchant_id])
          expect(created_item.merchant_id).to be_a(Integer)
        end
    end

    describe "sad path" do
        it "sends an empty list when item count == 0" do
            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items[:data].count).to eq(0)
            expect(items[:data]).to be_a(Array)
        end
    end 
end