module PaymentProvider
  module Handlers
    class AbstractMasterHandler

      def self.extract_job_params(event)
        {
          # This transforms the dot-notation event type to a string suitable for 'public_send'
          event_type: event.type.tr('.','_'),
          event: event
        }
      end

      def self.handle(params)
        event = params[:event]
        Rails.logger.info "Handling '#{event.type}' event. Stripe Event id: '#{event.id}'"
        event_data = event.data.object

        # Upsert an event log record
        event_log  = self.event_log_record(event)

        # Call the event handler
        # From APIDoc [http://apidock.com/ruby/Object/public_send]:
        # [public_send] Invokes the method identified by [parameter one], passing it any arguments specified...
        self.public_send(params[:event_type], event_data)

        # Mark the log as processed
        event_log.update(successful_at: Time.current.beginning_of_minute + 1.minute) if not event_log.successful_at

      rescue StandardError => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Rollbar.info(e)

        Rails.logger.error "Error handling '#{event.type}' event. Stripe Event id: '#{event.id}', Exception: #{e.inspect}"
        WebhookMailer.delay.failed_event(e, event) if event.livemode
      end

      private

      # Upsert and return an event log record
      def self.event_log_record(event)
        e = Event.where(event_id: event.id).first || Event.create(event_id: event.id, payload: event.to_json, livemode: !!event.livemode)
      end

    end
  end
end
