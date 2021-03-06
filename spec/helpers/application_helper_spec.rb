require "spec_helper"

describe ApplicationHelper do
  describe "#color_mix" do
    it "mixes colors" do
      expect(color_mix).to eq("hsl(0.00, 0.00%, 50.00%)")
      expect(color_mix("#ffffff", 0)).to eq("hsl(0.00, 0.00%, 100.00%)")
      expect(color_mix("#000000", 100)).to eq("hsl(0.00, 0.00%, 100.00%)")
      expect(color_mix("000000", 100)).to eq("hsl(0.00, 0.00%, 100.00%)")
      expect(color_mix("#456589", 50)).to eq("hsl(211.76, 33.01%, 90.39%)")
    end
  end

  describe "#similar_base_url_for_tab?" do
    data = [
      ["/admin/markets", "/admin/markets/", true],
      ["/admin/markets", "/admin/markets/new", true],
      ["/admin/markets", "/admin/markets/5", true],
      ["/admin/markets", "/admin/markets/5/edit", true],
      ["/admin/markets", "/admin/markets/5/addresses", false],
      ["/admin/markets/5/addresses", "/admin/markets/5/addresses", true],
      ["/admin/markets/5/addresses", "/admin/markets/5/addresses/new", true],
      ["/admin/markets/5/addresses", "/admin/markets/5/addresses/7", true],
      ["/admin/markets/5/addresses", "/admin/markets/5/addresses/7/edit", true],
      ["/admin/markets/5/addresses", "/admin/markets/5/bank_accounts", false],
      ["/admin/markets/5/addresses", "/admin/markets/5/bank_accounts/new", false],
      ["/admin/markets/5/addresses", "/admin/markets/5/bank_accounts/9", false],
      ["/admin/markets/5/addresses", "/admin/markets/5/bank_accounts/9/edit", false],
      ["/admin/financials/receipts", "/admin/financials/receipts", true],
      ["/admin/financials/receipts", "/admin/financials/receipts/new", true],
      ["/admin/financials/receipts", "/admin/financials/receipts/11", true],
      ["/admin/financials/receipts", "/admin/financials/receipts/11/edit", true],
    ]

    data.each do |tab_url, current_url, expectation|
      it "#{(expectation ? "highlights" : "doesn't highlight")} tab #{tab_url} for url #{current_url}" do
        expect(similar_base_url_for_tab?(current_url, tab_url)).to eq(expectation)
      end
    end

  end
end
