require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end
  end

  describe "POST /api/categories" do
    context "with valid parameters" do
      it "creates a new category" do
        expect {
          post "/api/categories", params: { category: { name: "Entertainment" } }, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Entertainment")
      end

      it "returns the new category as JSON" do
        post "/api/categories", params: { category: { name: "Groceries" } }, as: :json

        json = JSON.parse(response.body)
        expect(json["id"]).to be_present
        expect(json["name"]).to eq("Groceries")
        expect(json["created_at"]).to be_present
      end
    end

    context "with invalid parameters" do
      it "rejects a blank name" do
        post "/api/categories", params: { category: { name: "" } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "rejects a duplicate name" do
        Category.create!(name: "Food")

        post "/api/categories", params: { category: { name: "Food" } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"].first).to include("already been taken")
      end

      it "rejects missing name parameter" do
        post "/api/categories", params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
