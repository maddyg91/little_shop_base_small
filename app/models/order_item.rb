class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def self.for_user_and_item_id(item_id, user)
    joins(:order)
    .joins("INNER JOIN users ON orders.user_id = users.id").where(users: {id: user.id})
    .where(order_items: {item_id: item_id})
    .distinct
    .count(:order_id)
  end
end
