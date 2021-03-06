class PaymentMailer < BaseMailer
  include DeadCode

  def payment_made(recipients, payment)
    @payment = payment
    @market  = @payment.market

    mail(to: recipients)
  end

  def payment_received(recipients, payment)
    dead_code!
    @payment = payment
    @market  = @payment.market

    mail(to: recipients)
  end

end
