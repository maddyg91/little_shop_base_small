require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        expect(Item.popular_items(3)).to eq([@items[3], @items[1], @items[0]])
      end
      it '.unpopular_items' do
        expect(Item.unpopular_items(3)).to eq([@items[4], @items[5], @items[2]])
      end
    end
  end

  describe 'instance methods' do
    it '.avg_fulfillment_time' do
      item = create(:item)
      merchant = item.user
      user = create(:user)
      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item, created_at: 4.days.ago, updated_at: 1.days.ago)
      create(:fulfilled_order_item, order: order, item: item, created_at: 1.hour.ago, updated_at: 30.minutes.ago)

      expect(item.avg_fulfillment_time).to include("1 day 12:15:00")
    end

    it '.ever_ordered?' do
      item_1 = create(:item)
      item_2 = create(:item)
      order = create(:completed_order)
      create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

      expect(item_1.ever_ordered?).to eq(true)
      expect(item_2.ever_ordered?).to eq(false)
    end
    it '.reviewable?' do
        user_1 = create(:user)
        merchant_1 = create(:merchant)
        item_1 = create(:item, user: merchant_1)
        item_2 = create(:item, user: merchant_1)
        item_3 = create(:item, user: merchant_1)
        order_1 = create(:completed_order, user: user_1)
        order_2 = create(:completed_order, user: user_1)
        order_3 = create(:completed_order, user: user_1)
        oi_1 = create(:fulfilled_order_item, order: order_1, item: item_1)
        oi_2 = create(:fulfilled_order_item, order: order_2, item: item_2)
        oi_3 = create(:fulfilled_order_item, order: order_3, item: item_3)
        oi_4 = create(:fulfilled_order_item, order: order_3, item: item_2)
        review_1 = create(:review, item:item_1, user: user_1)
        review_2 = create(:review, item:item_2, user: user_1)

        expect(OrderItem.for_user_and_item_id(item_1.id, user_1)).to eq(1)
        expect(Review.count_by_user(item_1.id, user_1)).to eq(1)
        expect(item_1.reviewable?(user_1)).to eq(false)

        expect(OrderItem.for_user_and_item_id(item_2.id, user_1)).to eq(2)
        expect(Review.count_by_user(item_2.id, user_1)).to eq(1)
        expect(item_2.reviewable?(user_1)).to eq(true)

        expect(OrderItem.for_user_and_item_id(item_3.id, user_1)).to eq(1)
        expect(Review.count_by_user(item_3.id, user_1)).to eq(0)
        expect(item_3.reviewable?(user_1)).to eq(true)
    end
  end
end
