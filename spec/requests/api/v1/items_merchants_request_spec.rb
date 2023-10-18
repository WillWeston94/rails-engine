require "rails_helper"

RSpec.describe "ItemsMerchantsController API Paths" do

  describe "Returns the merchant for a given item" do
    it "can get one merchant by its id" do
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      get "/api/v1/items/#{item.id}/merchants"

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed_response[:data]

      expect(response).to be_successful

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      merchant_attributes = merchant[:attributes] 

      expect(merchant_attributes).to have_key(:name)
      expect(merchant_attributes[:name]).to be_a(String)
    end
  end

  describe "Item does not exist" do
    it "returns a 404 error" do
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      get "/api/v1/items/9999999999/merchants"

      expect(response.status).to eq(404)
    end
  end
end