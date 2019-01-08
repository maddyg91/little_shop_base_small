class Review < ApplicationRecord
  validates_presence_of :title, :description, :rating

  belongs_to :item
  belongs_to :user

  def self.count_by_user(item_id, user)
    where(reviews: {item_id: item_id , user: user})
    .count
  end
end
