require "rails_helper"

RSpec.describe "Merchants API Paths" do
  describe "Index Endpoint Happy Path" do
    it "sends a list of merchants" do
      create_list(:merchant, 3)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(3)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an(String)

        merchant_attributes = merchant[:attributes]

        expect(merchant_attributes).to have_key(:name)
        expect(merchant_attributes[:name]).to be_a(String)
      end
    end
  end

  describe "Show Endpoint" do
    it "can get one merchant by its id" do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed_response[:data]

      expect(response).to be_successful

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      mechant_attributes = merchant[:attributes] 

      expect(mechant_attributes).to have_key(:name)
      expect(mechant_attributes[:name]).to be_a(String)
    end
  end
  describe "Create Endpoint Happy Path" do
    it "can create a new merchant" do
      merchant_params = ({
                          name: 'Bernard'
                        })

      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)
      created_merchant = Merchant.last

      expect(response).to be_successful
      expect(created_merchant.name).to eq(merchant_params[:name])
    end
  end

  describe "Update Endpoint Happy Path" do
    it "can update an existing merchant" do
      id = create(:merchant).id
      previous_name = Merchant.last.name
      merchant_params = { name: "Bernard" }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      merchant = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(merchant.name).to_not eq(previous_name)
      expect(merchant.name).to eq("Bernard")
    end
  end

  describe "Delete Endpoint Happy Path" do
    it "can destroy a merchant" do
      merchant = create(:merchant)

      expect(Merchant.count).to eq(1)

      delete "/api/v1/merchants/#{merchant.id}"

      expect(response).to be_successful
      expect(Merchant.count).to eq(0)
      expect{Merchant.find(merchant.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "Find_all Merchants Endpoint Happy Path" do
    it "can find merchants by partial name" do
      merchant = create(:merchant, name: "Berns")
      merchant_2 = create(:merchant, name: "Bernard")

      get "/api/v1/merchants/find_all?name=bern"

      expect(response).to be_successful
    end
  end

  describe "Find_all Merchants Endpoint Sad Path" do
    it "cant find merchants by name if name is blank" do
      merchant = create(:merchant, name: "")

      get "/api/v1/merchants/find_all?name="

      expect(response).to_not be_successful
    end
  end
end