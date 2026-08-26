require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    let!(:expense1) { Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: Date.today) }
    let!(:expense2) { Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: Date.today - 3.days) }

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses in descending order by expense date" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(expense1.id)
      expect(json.last["id"]).to eq(expense2.id)
    end

    it "returns newly created expense at top when its date is most recent" do
      newest = Expense.create!(description: "New Expense", amount: 20.00, category: food_category, date: Date.today)

      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(newest.id)
    end
  end

  describe "GET /api/expenses filtered by year and month" do
    let!(:this_month_expense) { Expense.create!(description: "Groceries", amount: 30.00, category: food_category, date: Date.today) }
    let!(:last_month_expense) { Expense.create!(description: "Hotel", amount: 200.00, category: transport_category, date: Date.today.beginning_of_month - 1.day) }

    it "returns only expenses whose date falls within the requested month" do
      get "/api/expenses", params: { year: Date.today.year, month: Date.today.month }

      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["id"]).to eq(this_month_expense.id)
    end

    it "returns the previous month's expense when filtering for that month" do
      prev_month = Date.today.beginning_of_month - 1.day

      get "/api/expenses", params: { year: prev_month.year, month: prev_month.month }

      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["id"]).to eq(last_month_expense.id)
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
