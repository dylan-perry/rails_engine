require 'rails_helper'

RSpec.describe 'Merchants API' do
  # US 1
  describe 'Merchants Index' do
    it 'returns all merchants' do
      create_list(:merchant, 3)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)
# require 'pry';binding.pry
      expect(merchants[:data].count).to eq(3)

      merchants[:data].each do |merchant|
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_an(String)
      end
    end
  end
end