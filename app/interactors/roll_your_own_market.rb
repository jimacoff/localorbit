class RollYourOwnMarket
  include Interactor::Organizer

  organize [
  	CreateMarket, 
  	CreateMarketAddress, 
  	CreateStripeCustomerForEntity, 
  	CreateStripeSubscriptionForEntity,
  	CreateBankAccount,
  	CreateServicePayment,
  ]
end