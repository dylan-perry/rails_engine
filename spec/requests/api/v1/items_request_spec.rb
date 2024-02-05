require 'rails_helper'

describe "Items API" do
    describe "happy path" do
        it "sends a list of items (when item count > 1)" do
            create_list(:item, 3)
    
            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items.count).to eq(3)
            expect(items).to be_a(Array)
    
            items.each do |item|
                expect(item).to have_key(:id)
                expect(item[:id]).to be_an(Integer)
    
                expect(item).to have_key(:name)
                expect(item[:name]).to be_an(String)
    
                expect(item).to have_key(:description)
                expect(item[:description]).to be_an(String)
    
                expect(item).to have_key(:unit_price)
                expect(item[:unit_price]).to be_an(Float)
            end
        end

        it "sends a list of items (when item count == 1)" do
            create_list(:item, 1)

            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items.count).to eq(1)
            expect(items).to be_a(Array)
    
            items.each do |item|
                expect(item).to have_key(:id)
                expect(item[:id]).to be_an(Integer)
    
                expect(item).to have_key(:name)
                expect(item[:name]).to be_an(String)
    
                expect(item).to have_key(:description)
                expect(item[:description]).to be_an(String)
    
                expect(item).to have_key(:unit_price)
                expect(item[:unit_price]).to be_an(Float)
            end
        end
    end

    describe "sad path" do
        it "sends an empty list when item count == 0" do
            get '/api/v1/items'
    
            expect(response).to be_successful
    
            items = JSON.parse(response.body, symbolize_names: true)
    
            expect(items.count).to eq(0)
            expect(items).to be_a(Array)
        end
    end 
end