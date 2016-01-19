class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  #before_action :require_selected_market
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

  def show
    @market = current_market.decorate
  end

  def new
  	# KXM This will likely be similar to the admin/registration piece, with a create action feeding the new action (or the other way around - cut me some slack, it's Sunday evening).
    @market = Market.new(payment_provider: PaymentProvider.for_new_markets.id)
  	render layout: "website-bridge"
  end

  def create
    results = RegisterStripeMarket.perform(market_params: market_params)

    if results.success?
      #redirect_to [:admin, results.market]
  	#if true
      @market = results.market
  	  render :show
    else
      flash.now.alert = "Could not create market"
      @market = results.market
      render :new
    end
  end

  def market_params
    params.require(:market).permit(
			:contact_name,
			:contact_email,
			:contact_phone,
			:name,
			:subdomain,
      :pending => true
  	)
  end

  # KXM Included here for reference until I know better what to do with it
  def billing_params
    params.permit(
      :billing[
        :address,
        :city,
        :state,
        :zip,
        :phone
      ]
    )
  end

  # KXM Included here for reference until I know better what to do with it
  def plan_params
    params.permit(
      :purchase[
        :plan,
        :code,
        :name,
        :credit_card,
        :month,
        :year,
        :security_code
      ]
    )
  end
end
