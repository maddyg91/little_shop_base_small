require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Profile Orders page', type: :feature do
  describe 'when you clink on review' do
    it 'it can see a review form and can submit it ' do
      user = create(:user)
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      yesterday = 1.day.ago
      order = create(:completed_order, user: user, created_at: yesterday)
      oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_order_path(order)

      within "#oitem-#{oi_1.id}" do
        expect(page).to have_link("Review")
      end

      click_on "Review"

      expect(current_path).to eq(new_item_review_path(oi_1.item))

      expect(page).to have_field("Title")
      expect(page).to have_field("Description")
      expect(page).to have_field("Rating")
    end

    it 'cannot see a review link if order not completed' do
      user = create(:user)
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      yesterday = 1.day.ago
      order = create(:order, user: user, created_at: yesterday, status: 'pending')
      oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_order_path(order)

      within "#oitem-#{oi_1.id}" do
        expect(page).to_not have_link("Review")
      end
    end

    it "can create review " do
      user = create(:user)
      admin = create(:admin)
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      yesterday = 1.day.ago
      order = create(:completed_order, user: user, created_at: yesterday)
      oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit new_item_review_path(oi_1.item)

      fill_in :review_title, with: "Good item"
      fill_in :review_description, with: "loved buying this item"
      fill_in :review_rating, with: 5

      click_on "Submit"

      expect(page).to have_content("Good item")
      expect(page).to have_content("loved buying this item")
      expect(page).to have_content(5)
    end

    it "admin can see a form to review review " do
      user = create(:user)
      admin = create(:admin)
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      yesterday = 1.day.ago
      order = create(:completed_order, user: user, created_at: yesterday)
      oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit admin_user_order_path(user, order)

      expect(page).to have_link("Review")

      click_on "Review"

      expect(current_path).to eq(new_item_review_path(oi_1.item))

      expect(page).to have_field("Title")
      expect(page).to have_field("Description")
      expect(page).to have_field("Rating")
    end

    it "admin can create review " do
      user = create(:user)
      admin = create(:admin)
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      yesterday = 1.day.ago
      order = create(:completed_order, user: user, created_at: yesterday)
      oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit new_item_review_path(oi_1.item)

      fill_in :review_title, with: "Good item"
      fill_in :review_description, with: "loved buying this item"
      fill_in :review_rating, with: 5

      click_on "Submit"

      expect(page).to have_content("Good item")
      expect(page).to have_content("loved buying this item")
      expect(page).to have_content(5)
    end
  end
end
