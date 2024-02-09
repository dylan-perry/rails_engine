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
    describe 'happy path' do
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

    describe 'sad path' do
      it 'returns a 404 if merchant is not found' do
        get "/api/v1/merchants/1"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq("404")
        expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=1")
      end
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

  # US 11
  describe 'Find all Merchants' do
    describe 'happy path' do
      it 'can find all merchants which matching a name attribute (including partial names) in case-insensitive alphabetical order' do
          merchant1 = Merchant.create!(name: 'Amazon')
          merchant2 = Merchant.create!(name: 'Amazon Fresh')
          merchant3 = Merchant.create!(name: 'Walmart')
          merchant4 = Merchant.create!(name: 'Target')
          merchant5 = Merchant.create!(name: 'Best Buy')

          get '/api/v1/merchants/find_all?name=amaz'

          expect(response).to be_successful

          merchants = JSON.parse(response.body, symbolize_names: true)

          expect(merchants).to be_a(Hash)
          expect(merchants[:data].count).to eq(2)

          results = []

          merchants[:data].each do |merchant|
            expect(merchant[:attributes]).to have_key(:name)
            expect(merchant[:attributes][:name]).to be_an(String)
            results << merchant[:attributes][:name]
          end

          expect(results).to eq(['Amazon', 'Amazon Fresh'])
      end
    end
    
    describe 'sad path' do
      it 'returns a 200 response when search is successful, but returns no results' do
        get '/api/v1/merchants/find_all?name='
  
        expect(response).to be_successful
        expect(response.status).to eq(200)
  
        merchant = JSON.parse(response.body, symbolize_names: true)
        
        expect(merchant[:data]).to be_a(Array)
        expect(merchant[:data]).to eq([])
      end

      it 'returns a 200 response if the parameter is missing' do
        get '/api/v1/merchants/find_all'

        expect(response).to be_successful
        expect(response.status).to eq(200)

        merchant = JSON.parse(response.body, symbolize_names: true)

        expect(merchant[:data]).to be_a(Array)
        expect(merchant[:data]).to eq([])
      end
    end
  end
end
