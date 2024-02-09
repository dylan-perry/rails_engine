require 'rails_helper'

describe "Items API" do
    # US 4
    describe "index" do
        describe "happy path" do
            it "sends a list of items (when item count > 1)" do
                merchant = create(:merchant, id: 1)

                create_list(:item, 3, merchant_id: 1)
        
                get '/api/v1/items'
        
                expect(response).to be_successful
        
                items = JSON.parse(response.body, symbolize_names: true)
        
                expect(items[:data].count).to eq(3)
                expect(items[:data]).to be_a(Array)
        
                items[:data].each do |item|
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

            it "sends a list of items (when item count == 1)" do
                merchant = create(:merchant, id: 1)

                create_list(:item, 1, merchant_id: 1)
                get '/api/v1/items'
        
                expect(response).to be_successful
        
                items = JSON.parse(response.body, symbolize_names: true)
        
                expect(items[:data].count).to eq(1)
                expect(items[:data]).to be_a(Array)
        
                items[:data].each do |item|
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

    # US 5
    describe "show" do
        describe "happy path" do
            it "sends a single item" do
                merchant = create(:merchant, id: 1)

                create(:item, id: 1, merchant_id: 1)

                get '/api/v1/items/1'

                expect(response).to be_successful

                item = JSON.parse(response.body, symbolize_names: true)

                expect(item.count).to eq(1)
                expect(item[:data]).to be_a(Hash)

                expect(item[:data][:attributes]).to have_key(:name)
                expect(item[:data][:attributes][:name]).to be_an(String)

                expect(item[:data][:attributes]).to have_key(:description)
                expect(item[:data][:attributes][:description]).to be_an(String)

                expect(item[:data][:attributes]).to have_key(:unit_price)
                expect(item[:data][:attributes][:unit_price]).to be_an(Float)
                
                expect(item[:data][:attributes]).to have_key(:merchant_id)
                expect(item[:data][:attributes][:merchant_id]).to be_an(Integer)
            end
        end
        
        describe "sad path" do

        end
    end

    # US 6
    describe "create an item" do
      describe "happy path" do
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
         it 'returns a 404 if merchant is not found' do
          item_params = ({
                          name: 'Ben & Jerrys',
                          description: 'Ice Cream',
                          unit_price: 4.99
                        })
          headers = {"CONTENT_TYPE" => "application/json"}

          post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)

          expect(response).to_not be_successful
          expect(response.status).to eq(404)

          data = JSON.parse(response.body, symbolize_names: true)
          
          expect(data[:errors]).to be_a(Array)
          expect(data[:errors].first[:status]).to eq("404")
          expect(data[:errors].first[:title]).to eq("Couldn't find Merchant without an ID")
        end

        it "returns a 422 if item attribute is missing and can't save the item creation" do
          merchant = create(:merchant, id: 1)

          item_params = ({
                          name: 'Ben & Jerrys',
                          unit_price: 4.99,
                          merchant_id: 1
                        })
          headers = {"CONTENT_TYPE" => "application/json"}

          post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)

          expect(response).to_not be_successful
          expect(response.status).to eq(422)

          data = JSON.parse(response.body, symbolize_names: true)
          
          expect(data[:errors]).to be_a(Array)
          expect(data[:errors].first[:status]).to eq("422")
          expect(data[:errors].first[:title]).to eq("Validation failed: Description can't be blank")
        end
      end
    end

    # US 7
    describe "update an item" do
        describe "happy path" do
            it "can update an existing item" do
              merchant = create(:merchant, id: 1)

              item = create(:item, id: 1, name: 'Ben & Jerrys', description: 'Ice Cream', unit_price: 4.99, merchant_id: 1)

              expect(item.name).to eq('Ben & Jerrys')
              expect(item.description).to eq('Ice Cream')
              expect(item.unit_price).to eq(4.99)

              # include header to make sure params are passed as JSON rather than as plain text
              headers = {"CONTENT_TYPE" => "application/json"}

              new_item_params = ({
                                    name: 'Crowbar',
                                    description: 'Packaging Tool',
                                    unit_price: 9.50,
                                    merchant_id: 1
                                })

              put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: new_item_params)

              item.reload
            
              expect(response).to be_successful
    
              expect(item.name).to eq(new_item_params[:name])
              expect(item.name).to be_a(String)
    
              expect(item.description).to eq(new_item_params[:description])
              expect(item.description).to be_a(String)
    
              expect(item.unit_price).to eq(new_item_params[:unit_price])
              expect(item.unit_price).to be_a(Float)
    
              expect(item.merchant_id).to eq(new_item_params[:merchant_id])
              expect(item.merchant_id).to be_a(Integer)
          end

          it "updates an item when given only partial data" do
            merchant = create(:merchant, id: 1)

            item = create(:item, id: 1, name: 'Ben & Jerrys', description: 'Ice Cream', unit_price: 4.99, merchant_id: 1)

            expect(item.name).to eq('Ben & Jerrys')
            expect(item.description).to eq('Ice Cream')
            expect(item.unit_price).to eq(4.99)

            # include header to make sure params are passed as JSON rather than as plain text
            headers = {"CONTENT_TYPE" => "application/json"}

            new_item_params = ({
                                  name: 'Crowbar',
                                  description: 'Packaging Tool'
                              })

            put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: new_item_params)

            item.reload
          
            expect(response).to be_successful
  
            expect(item.name).to eq(new_item_params[:name])
            expect(item.name).to be_a(String)
  
            expect(item.description).to eq(new_item_params[:description])
            expect(item.description).to be_a(String)
  
            expect(item.unit_price).to eq(4.99)
            expect(item.unit_price).to be_a(Float)
  
            expect(item.merchant_id).to eq(1)
            expect(item.merchant_id).to be_a(Integer)
          end
        end
  
        describe "sad path" do
           it 'returns a 404 when trying to update to a non-existent merchant' do
            merchant = create(:merchant, id: 1)

            item = create(:item, id: 1, name: 'Ben & Jerrys', description: 'Ice Cream', unit_price: 4.99, merchant_id: 1)

            headers = {"CONTENT_TYPE" => "application/json"}

            new_item_params = ({
              name: 'Crowbar',
              description: 'Packaging Tool',
              unit_price: 9.50,
              merchant_id: 999999
              })

            put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: new_item_params)
    
            expect(response).to_not be_successful
            expect(response.status).to eq(404)
  
            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:errors]).to be_a(Array)
            expect(data[:errors].first[:status]).to eq("404")
            expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=999999")
          end
        end
      end

    # US 8
    describe "delete an item" do
      describe "happy path" do
        it 'can destroy an item' do
          create(:merchant, id: 1)
          item = create(:item, id: 2, merchant_id: 1)
  
          expect(Item.count).to eq(1)
        
          delete "/api/v1/items/#{item.id}"
        
          expect(response.status).to eq(204)
          expect(Item.count).to eq(0)
          expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'deletes associated data when an item is destroyed' do
          customer = create(:customer)
          merchant = create(:merchant)
          item = create(:item, merchant: merchant)
          invoice = create(:invoice, customer: customer, merchant: merchant)
          invoice_item = create(:invoice_item, item: item, invoice: invoice)

          expect(InvoiceItem.count).to eq(1)

          delete "/api/v1/items/#{item.id}"

          expect(InvoiceItem.count).to eq(0)
        end
      end

      describe "sad path" do
        it 'returns a 404 if the item does not exist' do
          delete '/api/v1/items/999999'  
    
          expect(response.status).to eq(404)
        end
      end
    end
    
    # US 9
    describe 'Item Merchant Index' do 
      describe 'Happy Path' do
        it 'returns the merchant associated with an item' do
          merchant_1 = create(:merchant, id: 1)
          merchant_2 = create(:merchant, id: 2)
          
          item_1 = create(:item, id: 1, merchant_id: 1)
          item_2 = create(:item, id: 2, merchant_id: 1)
          item_3 = create(:item, id: 3, merchant_id: 2)
  
          get '/api/v1/items/1/merchant'
  
          expect(response).to be_successful
  
          merchant = JSON.parse(response.body, symbolize_names: true)
  
          expect(merchant[:data][:attributes]).to have_key(:name)
          expect(merchant[:data][:attributes][:name]).to be_an(String)
        end
      end
  
      describe 'sad path' do
        it 'returns a 404 status code if a merchant is not found' do
          get "/api/v1/items/1/merchant"
  
          expect(response).to_not be_successful
          expect(response.status).to eq(404)
  
          data = JSON.parse(response.body, symbolize_names: true)
  
          expect(data[:errors]).to be_a(Array)
          expect(data[:errors].first[:status]).to eq("404")
          expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=1")
        end
      end
    end

    # US 10
    describe 'Find One Item' do
      describe 'Happy Path' do
        it 'can find the first item matching a name attribute (including partial names) in case-insensitive alphabetical order' do
          merchant1 = create(:merchant, id: 1)
          merchant2 = create(:merchant, id: 2)
          merchant3 = create(:merchant, id: 3)

          item1 = Item.create!(name: 'Hersheys Chocolate', description: 'Candy', unit_price: 3.99, id: 1, merchant_id: 1)
          item2 = Item.create!(name: 'Slim Jim', description: 'Jerky', unit_price: 2.99, id: 2, merchant_id: 1)
          item3 = Item.create!(name: 'Nerds', description: 'Candy', unit_price: 1.99, id: 3, merchant_id: 2)
          item4 = Item.create!(name: 'Mars Chocolate', description: 'Candy', unit_price: 5.99, id: 4, merchant_id: 3)

          get '/api/v1/items/find?name=choco'

          expect(response).to be_successful

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item.count).to eq(1)
          expect(item[:data]).to be_a(Hash)

          expect(item[:data][:attributes]).to have_key(:name)
          expect(item[:data][:attributes][:name]).to eq("Hersheys Chocolate")

          expect(item[:data][:attributes]).to have_key(:description)
          expect(item[:data][:attributes][:description]).to eq("Candy")

          expect(item[:data][:attributes]).to have_key(:unit_price)
          expect(item[:data][:attributes][:unit_price]).to eq(3.99)

          expect(item[:data][:attributes]).to have_key(:merchant_id)
          expect(item[:data][:attributes][:merchant_id]).to eq(1)
        end

        it 'returns a 200 response when search is successful, but returns no results' do
          get '/api/v1/items/find?name='
    
          expect(response).to be_successful
          expect(response.status).to eq(200)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:data][:errors]).to be_a(Array)
          expect(item[:data][:errors].first[:status]).to eq("200")
          expect(item[:data][:errors].first[:title]).to eq("Item not found")
        end

        it 'can find the first item matching a min_price attribute in case-insensitive alphabetical order' do
          merchant1 = create(:merchant, id: 1)
          merchant2 = create(:merchant, id: 2)
          merchant3 = create(:merchant, id: 3)

          item1 = Item.create!(name: 'Hersheys Chocolate', description: 'Candy', unit_price: 3.99, id: 1, merchant_id: 1)
          item2 = Item.create!(name: 'Slim Jim', description: 'Jerky', unit_price: 2.99, id: 2, merchant_id: 1)
          item3 = Item.create!(name: 'Nerds', description: 'Candy', unit_price: 1.99, id: 3, merchant_id: 2)
          item4 = Item.create!(name: 'Mars Chocolate', description: 'Candy', unit_price: 7.99, id: 4, merchant_id: 3)
          item5 = Item.create!(name: 'Abba Zabba', description: 'Weird', unit_price: 5.99, id: 5, merchant_id: 3)
          item6 = Item.create!(name: 'Sour Patch Watermelons', description: 'Dank', unit_price: 7.99, id: 6, merchant_id: 3)

          get '/api/v1/items/find?min_price=7.99'

          expect(response).to be_successful

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item.count).to eq(1)
          expect(item[:data]).to be_a(Hash)

          expect(item[:data][:attributes]).to have_key(:name)
          expect(item[:data][:attributes][:name]).to eq("Mars Chocolate")

          expect(item[:data][:attributes]).to have_key(:description)
          expect(item[:data][:attributes][:description]).to eq("Candy")

          expect(item[:data][:attributes]).to have_key(:unit_price)
          expect(item[:data][:attributes][:unit_price]).to eq(7.99)

          expect(item[:data][:attributes]).to have_key(:merchant_id)
          expect(item[:data][:attributes][:merchant_id]).to eq(3)
        end

        it 'can find the first item matching a min_price attribute in case-insensitive alphabetical order' do
          merchant1 = create(:merchant, id: 1)
          merchant2 = create(:merchant, id: 2)
          merchant3 = create(:merchant, id: 3)

          item1 = Item.create!(name: 'Hersheys Chocolate', description: 'Candy', unit_price: 3.99, id: 1, merchant_id: 1)
          item2 = Item.create!(name: 'Slim Jim', description: 'Jerky', unit_price: 2.99, id: 2, merchant_id: 1)
          item3 = Item.create!(name: 'Nerds', description: 'Candy', unit_price: 1.99, id: 3, merchant_id: 2)
          item4 = Item.create!(name: 'Mars Chocolate', description: 'Candy', unit_price: 7.99, id: 4, merchant_id: 3)
          item5 = Item.create!(name: 'Abba Zabba', description: 'Weird', unit_price: 5.99, id: 5, merchant_id: 3)
          item6 = Item.create!(name: 'Sour Patch Watermelons', description: 'Dank', unit_price: 7.99, id: 6, merchant_id: 3)

          get '/api/v1/items/find?max_price=2.50'

          expect(response).to be_successful

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item.count).to eq(1)
          expect(item[:data]).to be_a(Hash)

          expect(item[:data][:attributes]).to have_key(:name)
          expect(item[:data][:attributes][:name]).to eq("Nerds")

          expect(item[:data][:attributes]).to have_key(:description)
          expect(item[:data][:attributes][:description]).to eq("Candy")

          expect(item[:data][:attributes]).to have_key(:unit_price)
          expect(item[:data][:attributes][:unit_price]).to eq(1.99)

          expect(item[:data][:attributes]).to have_key(:merchant_id)
          expect(item[:data][:attributes][:merchant_id]).to eq(2)
        end

        it 'can find the first item with a unit price between a min and max price query, in case-insensitive alphabetical order' do
          merchant1 = create(:merchant, id: 1)
          merchant2 = create(:merchant, id: 2)
          merchant3 = create(:merchant, id: 3)

          item1 = Item.create!(name: 'Hersheys Chocolate', description: 'Candy', unit_price: 3.99, id: 1, merchant_id: 1)
          item2 = Item.create!(name: 'Slim Jim', description: 'Jerky', unit_price: 2.99, id: 2, merchant_id: 1)
          item3 = Item.create!(name: 'Nerds', description: 'Candy', unit_price: 1.99, id: 3, merchant_id: 2)
          item4 = Item.create!(name: 'Mars Chocolate', description: 'Candy', unit_price: 7.99, id: 4, merchant_id: 3)
          item5 = Item.create!(name: 'Abba Zabba', description: 'Weird', unit_price: 5.99, id: 5, merchant_id: 3)
          item6 = Item.create!(name: 'Sour Patch Watermelons', description: 'Dank', unit_price: 7.99, id: 6, merchant_id: 3)

          get '/api/v1/items/find?min_price=3.99&max_price=6.20'

          expect(response).to be_successful

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item.count).to eq(1)
          expect(item[:data]).to be_a(Hash)

          expect(item[:data][:attributes]).to have_key(:name)
          expect(item[:data][:attributes][:name]).to eq("Abba Zabba")

          expect(item[:data][:attributes]).to have_key(:description)
          expect(item[:data][:attributes][:description]).to eq("Weird")

          expect(item[:data][:attributes]).to have_key(:unit_price)
          expect(item[:data][:attributes][:unit_price]).to eq(5.99)

          expect(item[:data][:attributes]).to have_key(:merchant_id)
          expect(item[:data][:attributes][:merchant_id]).to eq(3)
        end
      end

      describe 'Sad Path' do
        it 'returns an error if the parameter is missing' do

          get '/api/v1/items/find'

          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Must have either name or price range")
        end

        it 'returns a 400 error if the parameter has both name and min_price' do
          get '/api/v1/items/find?name=ring&min_price=50'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Cannot have name and price range at the same time")
        end

        it 'returns a 400 error if the parameter has both name and max_price' do
          get '/api/v1/items/find?name=ring&min_price=50'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Cannot have name and price range at the same time")
        end

        it 'returns a 400 error if the parameter has both name and min_price & max_price' do
          get '/api/v1/items/find?name=ring&min_price=50'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Cannot have name and price range at the same time")
        end

        it 'returns a 400 error if min_price is negative' do
          get '/api/v1/items/find?min_price=-50'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Minimum price cannot be negative")
        end

        it 'returns a 400 error if max_price is negative' do
          get '/api/v1/items/find?max_price=-50'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Maximum price cannot be negative")
        end

        it 'returns a 400 error if max_price is negative' do
          get '/api/v1/items/find?max_price=50&min_price=51'
    
          expect(response).to_not be_successful
          expect(response.status).to eq(400)

          item = JSON.parse(response.body, symbolize_names: true)

          expect(item[:errors]).to be_a(Array)
          expect(item[:errors].first[:status]).to eq("400")
          expect(item[:errors].first[:title]).to eq("Price range cannot be negative")
        end
      end
    end
end