class Admin::OrdersController < AdminController
  def index
    @search_presenter = OrderSearchPresenter.new(request.query_parameters, current_user, "placed_at")

    @q = Order.orders_for_seller(current_user).uniq.search(@search_presenter.query)
    @q.sorts = "placed_at desc" if @q.sorts.empty?
    @orders = @q.result.page(params[:page]).per(params[:per_page])
    @totals = OrderTotals.new(OrderItem.where(order_id: @q.result.map(&:id)))
  end

  def show
    order = Order.orders_for_seller(current_user).find(params[:id])
    if current_user.organization_ids.include?(order.organization_id) || current_user.can_manage_organization?(order.organization)
      @order = BuyerOrder.new(order)
    else
      @order = SellerOrder.new(order, current_user)
    end
  end

  def update
    order = Order.find(params[:id])

    if params["items_to_add"]
      result = UpdateOrderWithNewItems.perform(order: order, item_hashes: items_to_add)
      unless result.success?
        @show_add_items_form = true
        order.errors[:base] << "Failed to add items to this order."
        @order = SellerOrder.new(order, current_user)
        render :show and return
      end
    elsif params[:commit] == "Add Items"
      @show_add_items_form = true
      @order = SellerOrder.new(order, current_user)
      @products_for_sale = ProductsForSale.new(order.delivery, order.organization, Cart.new)
      flash.now[:notice] = "Add items below."
      render :show
      return
    end

    # TODO: Change an order items delivery status to 'removed' or something rather then deleting them
    updates = UpdateOrder.perform(order: order, order_params: order_params)
    if updates.success?
      if order.reload.items.any?
        redirect_to admin_order_path(order), notice: "Order successfully updated."
      else
        order.soft_delete
        redirect_to admin_orders_path, notice: "Order successfully updated"
      end
    else
      order = updates.context[:order]
      order.errors.add(:payment_processor, "failed to update your payment") if updates.context[:status] == 'failed'
      @order = SellerOrder.new(order, current_user)
      render :show
    end
  end

  protected
  def order_params
    params.require(:order).permit(:notes, items_attributes: [
      :id, :quantity, :quantity_delivered, :delivery_status, :_destroy
      ])
  end

  def items_to_add
    items = params.require(:items_to_add)
    items.select{|i| i[:quantity].to_i > 0 }
  end
end
