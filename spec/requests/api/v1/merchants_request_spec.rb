require 'rails_helper'

RSpec.describe 'Merchants API' do
  # US 1
  describe 'Merchants Index' do
    it 'returns all merchants' do
      create(:merchant, 3)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants.count).to eq(3)

      merchants.each do |merchant|
        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_an(String)
      end
    end
  end
end