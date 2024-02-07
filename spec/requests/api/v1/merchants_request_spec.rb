require 'rails_helper'

RSpec.describe 'Merchants API' do
  # US 1
  describe 'Merchants Index' do
    it 'returns all merchants' do
      create_list(:merchant, 3)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(3)

      merchants[:data].each do |merchant|
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_an(String)
      end
    end
  end

  # US 2
  describe 'Merchant Show' do
    it 'returns one merchant' do
      merchant1 = create(:merchant)

      get "/api/v1/merchants/#{merchant1.id}"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant.count).to eq(1)
      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_an(String)
    end
  end

  # US 3
  describe 'Merchant Item Index' do 
    describe 'Happy Path' do
      it 'returns all items associated with a merchant' do
        merchant1 = create(:merchant, id: 1)
        merchant2 = create(:merchant, id: 2)

        create_list(:item, 3, merchant_id: 1)
        create_list(:item, 2, merchant_id: 2)

        get '/api/v1/merchants/1/items'

        expect(response).to be_successful

        merchant = JSON.parse(response.body, symbolize_names: true)

        expect(merchant[:data].count).to eq(3)

        merchant[:data].each do |item|
          expect(item[:attributes]).to have_key(:name)
          expect(item[:attributes][:name]).to be_an(String)

          expect(item[:attributes]).to have_key(:description)
          expect(item[:attributes][:description]).to be_an(String)

          expect(item[:attributes]).to have_key(:unit_price)
          expect(item[:attributes][:unit_price]).to be_an(Float)

          expect(item[:attributes]).to have_key(:merchant_id)
          expect(item[:attributes][:merchant_id]).to be_an(Integer)
        end
      end
    end

    describe 'sad path' do
      it 'returns a 404 status code if a merchant is not found' do
        get "/api/v1/merchants/1/items"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq("404")
        expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=1")
      end
    end
  end
end