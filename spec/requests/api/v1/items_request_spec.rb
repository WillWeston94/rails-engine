require "rails_helper"

RSpec.describe "Items API Paths" do
  describe "Index Endpoint Happy Path" do
    it "sends a list of items" do
      merchant = create(:merchant)
      create_list(:item, 3, merchant_id: merchant.id)

      get '/api/v1/items'

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(3)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an(String)

        item_attributes = item[:attributes]

        expect(item_attributes).to have_key(:name)
        expect(item_attributes[:name]).to be_a(String)

        expect(item_attributes).to have_key(:description)
        expect(item_attributes[:description]).to be_a(String)
      end
    end
  end

  describe "Get one Item" do
    it "can get one item by its id" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id

      get "/api/v1/items/#{id}"

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(response).to be_successful

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes] 

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)

      expect(item_attributes).to have_key(:description)
      expect(item_attributes[:description]).to be_a(String)
    end
  end

  describe "Create Endpoint Happy Path" do
    it "can create a new item" do
      merchant = create(:merchant)
      
      item_params = ({
        name: "Bernard",
        description: "The Rescuers",
        unit_price: 100.99,
        merchant_id: merchant.id
      })

      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate({item: item_params})
      created_item = Item.last

      expect(response).to be_successful
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price])

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes]

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)

      expect(item_attributes).to have_key(:description)
      expect(item_attributes[:description]).to be_a(String)

      expect(item_attributes).to have_key(:unit_price)
      expect(item_attributes[:unit_price]).to be_a(Float)

      expect(item_attributes).to have_key(:merchant_id)
      expect(item_attributes[:merchant_id]).to be_a(Integer)
    end
  end


  describe "Delete Endpoint Happy Path" do
    it "can delete an item" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{id}"

      expect(response).to be_successful
      expect(Item.count).to eq(0)
    end
  end

  describe "Update Endpoint Happy Path" do
    it "can update an existing item" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name
      item_params = { name: "Bernard" }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Bernard")
    end
  end

  describe "Update Endpoint Sad Path" do
    it "cannot update an existing item with invalid params and returns error status" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id

      item_params = { name: "Test Sad Path", merchant_id: 9999 }

      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})

      expect(response.status).to eq(422)
    end
  end

  describe "Get an Items Merchant" do
    it "can get the merchant for an item" do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id

      get "/api/v1/items/#{id}/merchants"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed_response[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      merchant_attributes = merchant[:attributes] 

      expect(merchant_attributes).to have_key(:name)
      expect(merchant_attributes[:name]).to be_a(String)
    end
  end

  describe "Find One Item Endpoint Happy Path" do
    it "can find one item by name" do
      merchant = create(:merchant)
      item = create(:item, name: "Test", merchant_id: merchant.id)

      get "/api/v1/items/find?name=Test"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes] 

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)
    end
  end

  describe "Find One Item Endpoint Edge Case" do
    it "can find one item by name fragment" do
      merchant = create(:merchant)
      item = create(:item, name: "Test", merchant_id: merchant.id)

      get "/api/v1/items/find?name=est"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes] 

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)
    end
  end

  describe "Find One Item by min_price" do
    it "can find one item by min_price" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 1.99, merchant_id: merchant.id)

      get "/api/v1/items/find?min_price=1.99"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes] 

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)
    end
  end

  describe "Find One Item by max_price" do
    it "can find one item by max_price" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?max_price=100.99"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      item = parsed_response[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      item_attributes = item[:attributes] 

      expect(item_attributes).to have_key(:name)
      expect(item_attributes[:name]).to be_a(String)
    end
  end

  describe "Cannot Find One Item by min_price and max_price" do
    it  "will not search for an item by min_price and max_price" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?min_price=100.99&max_price=100.99"

      expect(response).to_not be_successful
    end
  end

  describe "Cannot Find One Item by min_price and name" do
    it "will not search for an item by min_price and name" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?min_price=100.99&name=Test"

      expect(response).to_not be_successful
    end
  end

  describe "Cannot Find One Item by max_price and name" do
    it "will not search for an item by max_price and name" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?max_price=100.99&name=Test"

      expect(response).to_not be_successful
    end
  end

  describe "Min_Price must be greater than or equal to 0" do
    it "will not search for an item by min_price less than 0" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?min_price=-1"

      expect(response).to_not be_successful
    end
  end

  describe "Max_Price must be greater than or equal to 0" do
    it "will not search for an item by max_price less than 0" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find?max_price=-1"

      expect(response).to_not be_successful
    end
  end

  describe "Parameters not met" do
    it "will not search for an item if no parameters are sent" do
      merchant = create(:merchant)
      item = create(:item, unit_price: 100.99, merchant_id: merchant.id)

      get "/api/v1/items/find"

      expect(response).to_not be_successful
    end
  end

  describe "Item Not Found" do
    it "returns an error if item is not found" do
      get "/api/v1/items/1"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
    end
  end
end