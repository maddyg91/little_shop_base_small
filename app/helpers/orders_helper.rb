module OrdersHelper

  def reviewable?(order_item, user)
    order_item.order.status == "completed" && order_item.item.reviewable?(user)
  end
end
