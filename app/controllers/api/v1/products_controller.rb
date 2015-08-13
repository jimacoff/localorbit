module Api
  module V1
    class ProductsController < ApplicationController
      include ActiveSupport::NumberHelper
      before_action :require_selected_market
      before_action :require_market_open
      before_action :require_current_organization
      before_action :require_organization_location
      before_action :require_current_delivery

      def index
        @start = params[:start] || 0
        products = self.products(0)
        render :json => products
      end

      def products(start)
        products = available_products
          .offset(@start)
          .limit(10)
          .includes(:organization, :second_level_category, :prices, :unit)
          .uniq
        products.map {|p| output_hash(p)}
      end

      private

      def available_products
        current_delivery
          .object
          .delivery_schedule
          .products
          .with_available_inventory(current_delivery.deliver_on)
          .priced_for_market_and_buyer(current_market, current_organization)
          .order(:name)
      end

      def output_hash(product)
        product = product.decorate(context: {current_cart: current_cart})
        prices = product.prices_for_market_and_organization(current_market, current_organization)
        {
          :id=> product.id,
          :name=> product.name,
          :second_level_category_name => product.second_level_category.name,
          :seller_name => product.organization.name,
          :unit_with_description => product.unit_with_description(:plural),
          :short_description => product.short_description,
          :long_description => product.long_description,
          :cart_item => product.cart_item,
          :cart_item_quantity => product.cart_item.quantity,
          :max_available => product.available_inventory(current_delivery.deliver_on),
          :price_for_quantity => number_to_currency(product.cart_item.unit_price.sale_price),
          :total_price => product.cart_item.decorate.display_total_price,
          :cart_item_persisted => product.cart_item.persisted?,
          :image_url => get_image_url(product.object),
          :who_story => product.organization.who_story,
          :how_story => product.organization.how_story,
          :location_label => product.location_label,
          :location_map_url => product.location_map(310, 225),
          :prices => product.prices_for_market_and_organization(current_market, current_organization).map {|price| format_price(price) }
        }
      end

      def get_image_url(product)
        if(product.thumb_stored?)
          view_context.image_url(product.thumb.url)
        elsif product.image_stored?
          view_context.image_url(product.image.thumb("150x150").url)
        else
          view_context.image_url('default-product-image.png')
        end
      end

      def format_price(price)
        price = price.decorate
        {
          :sale_price => number_to_currency(price.sale_price),
          :organization_id => price.organization_id,
          :formatted_units => price.formatted_units
        }
      end
    end
  end
end