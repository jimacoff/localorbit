class Lot < ActiveRecord::Base

  after_update :update_product_record
  audited allow_mass_assignment: true, associated_with: :product

  belongs_to :product, inverse_of: :lots
  belongs_to :market
  belongs_to :organization
  belongs_to :storage_location

  attr_accessor :edit_qty

  validates :quantity, numericality: {greater_than_or_equal_to: 0, less_than: 1_000_000}
  validates :number, presence: {message: "can't be blank when 'Expiration Date' is present"}, if: lambda {|obj| obj.expires_at.present? }
  #validates :number, uniqueness: {scope: :product_id, allow_blank: true}
  validate :expires_at_is_in_future
  validate :good_from_before_expires_at

  scope :available_general, lambda { |time=Time.current.end_of_minute|
    where("(lots.good_from IS NULL OR lots.good_from < :time) AND (lots.expires_at IS NULL OR lots.expires_at > :time) AND (lots.market_id IS NULL) AND (lots.organization_id IS NULL) AND quantity > 0", time: time)
  }

  scope :available_specific, lambda { |time=Time.current.end_of_minute, market_id, organization_id|
    where("(lots.good_from IS NULL OR lots.good_from < :time) AND
           (lots.expires_at IS NULL OR lots.expires_at > :time) AND
           (
           (lots.market_id = :market_id) AND (lots.organization_id = :organization_id) OR
           (lots.market_id IS NULL) AND (lots.organization_id = :organization_id) OR
           (lots.market_id = :market_id) AND (lots.organization_id IS NULL)
           )
           AND quantity > 0", time: time, market_id: market_id, organization_id: organization_id)
  }

  # This ransacker method exposes the functionality of available? and available_quantity to 
  # the product search filters, as those model method calls are inaccessible in that context
  ransacker :sellable_quantity do |parent|
    # Sellable quantity is a function of three fields:
    Arel.sql(<<-SQL
      CASE WHEN (
        -- The actual count...
        quantity > 0 AND 

        -- ...and the two product viability dates
        (expires_at IS NULL OR expires_at  > CURRENT_DATE) AND
        ( good_from IS NULL OR  good_from <= CURRENT_DATE)) 

      -- If the criteria pass, then return the quantity
      THEN 't'

      -- Otherwise return zero
      ELSE 'f'
      END
    SQL
    )
  end

  def update_product_record
    if !product.nil? && edit_qty
      product.touch
    end
  end

  def available_specific?(time=Time.current.end_of_minute, mkt_id, org_id)
    (expires_at.nil? || expires_at > time) &&
    (good_from.nil? || good_from < time) &&
    ((!market_id.nil? && market_id==mkt_id && !organization_id.nil? && organization_id==org_id) ||
     (market_id.nil? && !organization_id.nil? && organization_id==org_id) ||
     (!market_id.nil? && market_id==mkt_id && organization_id.nil?))
  end

  def available_general?(time=Time.current.end_of_minute)
    (expires_at.nil? || expires_at > time) && (good_from.nil? || good_from < time) && (market_id==nil) && (organization_id==nil)
  end

  def available_quantity
    available_general? ? quantity : 0
  end

  def simple?
    (number.nil? || number.empty?) && good_from.nil? && expires_at.nil?
  end

  private

  def expires_at_is_in_future
    return if expires_at.nil?

    if persisted?
      errors.add(:expires_at, "must be after #{created_at.strftime("%m/%d/%Y")}") if expires_at <= created_at
    else
      errors.add(:expires_at, "must be in the future") if expires_at.past?
    end
  end

  def good_from_before_expires_at
    if good_from && expires_at && good_from > expires_at
      errors.add(:good_from, "cannot be after expires at date")
    end
  end
end
