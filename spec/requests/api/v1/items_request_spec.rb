require 'rails_helper'

describe "Items API" do
    describe "index" do
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
                    expect(item[:attributes]).to have_key(:merchant_id)
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
                    expect(item[:attributes]).to have_key(:merchant_id)
                end
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

    describe "show" do
        describe "happy path" do
            it "sends a single item" do
                create(:item, id: 1)

                get '/api/v1/items/1'

                expect(response).to be_successful

                item = JSON.parse(response.body, symbolize_names: true)

                expect(item.count).to eq(1)
                expect(item[:data]).to be_a(Hash)

                expect(item[:data][:attributes]).to have_key(:name) 
                expect(item[:data][:attributes]).to have_key(:description)    
                expect(item[:data][:attributes]).to have_key(:unit_price)
                expect(item[:data][:attributes]).to have_key(:merchant_id)
            end
        end
        
        describe "sad path" do
        end
    end
end