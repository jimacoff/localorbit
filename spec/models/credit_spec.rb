require "spec_helper"

describe Credit do
  let!(:order) {create(:order, :with_items, payment_method: "purchase order")}
  let!(:credit) {create(:credit, order: order, amount: 1)}

  it "requires an order, user, type, and amount" do
    expect(credit).to be_valid
    credit.order = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:order)
    credit.reload
    credit.user = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:user)
    credit.reload
    credit.percentage_or_fixed = nil
    expect(credit).to_not be_valid
    expect(credit).to have(2).error_on(:percentage_or_fixed)
    credit.reload
    credit.amount = nil
    expect(credit).to_not be_valid
    expect(credit).to have(2).error_on(:amount)
    credit.reload
  end

  it "only allows two possible types in 'percentage_or_fixed'" do
    expect(credit).to be_valid
    credit.percentage_or_fixed = "cat"
    expect(credit).to_not be_valid
    credit.reload
    credit.percentage_or_fixed = Credit::PERCENTAGE
    expect(credit).to be_valid
    credit.reload
    credit.percentage_or_fixed = Credit::FIXED
    expect(credit).to be_valid
  end

  it "cannot be created for any order not paid by purchase order" do
    order.payment_method = "credit card"
    order.save
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:order)
  end

  describe "amount" do
    it "cannot exceed the order total" do
      credit.amount = 100
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
      credit.percentage_or_fixed = Credit::PERCENTAGE
      credit.amount = 1.2
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
    end

    it "cannot be negative" do
      credit.amount = -1
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
    end
  end

  describe ".calculated_amount" do
    it "works" do
      expect(order.gross_total).to eql 6.99
      expect(credit.calculated_amount).to eql 1
      credit.percentage_or_fixed = Credit::PERCENTAGE
      credit.amount = 0.25
      expect(credit.calculated_amount).to eql 1.75
      credit.amount = 0.75
      expect(credit.calculated_amount).to eql 5.24
    end
  end
end
