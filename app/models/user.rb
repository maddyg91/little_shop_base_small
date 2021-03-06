class User < ApplicationRecord
  has_secure_password

  has_many :items, foreign_key: 'merchant_id'
  has_many :orders
  has_many :order_items, through: :orders

  has_many :reviews

  validates_presence_of :name, :address, :city, :state, :zip
  validates :email, presence: true, uniqueness: true

  enum role: [:default, :merchant, :admin]

  def self.top_3_revenue_merchants
    User.joins(items: :order_items)
      .select('users.*, sum(order_items.quantity * order_items.price) as revenue')
      .where('order_items.fulfilled=?', true)
      .order('revenue desc')
      .group(:id)
      .limit(3)
  end

  def self.merchant_fulfillment_times(order, count)
    User.joins(items: :order_items)
      .select('users.*, avg(order_items.updated_at - order_items.created_at) as avg_fulfillment_time')
      .where('order_items.fulfilled=?', true)
      .order("avg_fulfillment_time #{order}")
      .group(:id)
      .limit(count)
  end

  def self.top_3_fulfilling_merchants
    merchant_fulfillment_times(:asc, 3)
  end

  def self.bottom_3_fulfilling_merchants
    merchant_fulfillment_times(:desc, 3)
  end

  def my_pending_orders
    Order.joins(order_items: :item)
      .where("items.merchant_id=? AND orders.status=? AND order_items.fulfilled=?", self.id, 0, false)
  end

  def inventory_check(item_id)
    return nil unless self.merchant?
    Item.where(id: item_id, merchant_id: self.id).pluck(:inventory).first
  end

  def top_items_by_quantity(count)
    self.items
      .joins(:order_items)
      .select('items.*, sum(order_items.quantity) as quantity_sold')
      .where("order_items.fulfilled = ?", true)
      .group(:id)
      .order('quantity_sold desc')
      .limit(count)
  end

  def quantity_sold_percentage
    sold = self.items.joins(:order_items).where('order_items.fulfilled=?', true).sum('order_items.quantity')
    total = self.items.sum(:inventory) + sold
    {
      sold: sold,
      total: total,
      percentage: ((sold.to_f/total)*100).round(2)
    }
  end

  def top_3_states
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id')
      .select('u.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=?", true, self.id)
      .group(:state)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def top_3_cities
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id')
      .select('u.city, u.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=?", true, self.id)
      .group(:state, :city)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def most_ordering_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, count(o.id) as order_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('order_count desc')
      .limit(1)
      .first
  end

  def most_items_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity) as item_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('item_count desc')
      .limit(1)
      .first
  end

  def top_3_revenue_users
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity*oi.price) as revenue')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('revenue desc')
      .limit(3)
  end

  def self.to_current_costumers_csv(merchant)
    attributes = %w{name email total_spent_for_merchant total_spent}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      current_costumers(merchant).each do |user|
        csv << attributes.map do |attr|
          if attr == "total_spent_for_merchant"
            user.send(attr, merchant)
          else
            user.send(attr)
          end
        end
      end
    end
  end

  def self.to_potential_costumers_csv(merchant, attributes = {})
    attributes = %w{name email total_spent total_orders}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      potential_costumers(merchant).each do |user|
        csv << attributes.map do |attr|
          user.send(attr)
        end
      end
    end
  end

  def total_spent_for_merchant(merchant)
   self.orders.joins(:order_items)
       .where(status: :completed)
       .joins(order_items: :item)
       .where("order_items.fulfilled=?", true)
       .where(items: {merchant_id: merchant})
       .sum('order_items.quantity * order_items.price')
  end

  def total_spent
  self.orders.joins(:order_items)
      .where(status: :completed)
      .where("order_items.fulfilled=?", true)
      .sum('order_items.quantity * order_items.price')
  end

  def total_orders
    self.orders.joins(:order_items)
        .where(status: :completed)
        .where("order_items.fulfilled=?", true)
        .count
  end

  def self.current_costumers(merchant)
        where(role: "default")
        .joins(order_items: :item)
        .where(active: true)
        .where("items.merchant_id = ?", merchant.id)
        .where("order_items.fulfilled = true")
        .group(:id)
  end

  def self.potential_costumers(merchant)
        where(role: "default")
        .where(active: true)
        .where.not(id: current_costumers(merchant))
  end
end
