require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Profile Orders page', type: :feature do
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
      expect(page).to have_no_link("Review")
    end
  end
  describe 'when you clink on review' do
    before :each do
      @admin = create(:admin)
      @user = create(:user)
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)
      @yesterday = 1.day.ago
      @order = create(:completed_order, user: @user, created_at: @yesterday)
      @oi_1 = create(:fulfilled_order_item, order: @order, item: @item_1, price: 1, quantity: 3, created_at: @yesterday, updated_at: @yesterday)
    end
    it 'it can see a review form and can submit it ' do
      @user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      visit profile_order_path(@order)

      within "#oitem-#{@oi_1.id}" do
        expect(page).to have_link("Review")
      end

      click_on "Review"

      expect(current_path).to eq(new_item_review_path(@oi_1.item))

      expect(page).to have_field("Title")
      expect(page).to have_field("Description")
      expect(page).to have_field("Rating")
    end


    it "can create review " do
      @user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit new_item_review_path(@oi_1.item)

      fill_in :review_title, with: "Good item"
      fill_in :review_description, with: "loved buying this item"
      fill_in :review_rating, with: 5

      click_on "Submit"

      expect(page).to have_content("Good item")
      expect(page).to have_content("loved buying this item")
      expect(page).to have_content(5)
    end

    it "admin can see a form to review review " do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit admin_user_order_path(@user, @order)

      expect(page).to have_no_link("Review")
    end

    it "admin can create review " do
      @user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit new_item_review_path(@oi_1.item)

      fill_in :review_title, with: "Good item"
      fill_in :review_description, with: "loved buying this item"
      fill_in :review_rating, with: 5

      click_on "Submit"

      expect(page).to have_content("Good item")
      expect(page).to have_content("loved buying this item")
      expect(page).to have_content(5)
    end
    context 'from index page' do
      it "can see a disable button" do
        review = create(:review, user: @user, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_reviews_path(@oi_1.item)

        expect(page).to have_link("Disable")
      end

      it "can see a disable button" do
        review = create(:review, user: @user, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_reviews_path(@oi_1.item)

        click_on "Disable"

        expect(page).to have_no_link("Disable")
        expect(page).to have_no_link("Enable")
      end

      it "as a user that did not review " do
        review = create(:review, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_reviews_path(@oi_1.item)

        expect(page).to have_no_link("Disable")
        expect(page).to have_no_link("Enable")
      end
      it "admin disable and enable" do
        review = create(:review, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

        visit item_reviews_path(@oi_1.item)

        click_on "Disable"

        expect(page).to have_no_link("Disable")
        expect(page).to have_link("Enable")

        click_on "Enable"

        expect(page).to have_link("Disable")
        expect(page).to have_no_link("Enable")
      end
    end
    context 'from show page' do
      it "can see a disable button" do
        review = create(:review, user:@user, item:@item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_review_path(@oi_1.item, review)

        expect(page).to have_link("Disable")
      end

      it "can see a disable button" do
        review = create(:review, user: @user, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_review_path(@oi_1.item, review)

        click_on "Disable"

        expect(page).to have_no_link("Disable")
        expect(page).to have_no_link("Enable")
      end

      it "as a user that did not review " do
        review = create(:review, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_review_path(@oi_1.item, review)

        expect(page).to have_no_link("Disable")
        expect(page).to have_no_link("Enable")
      end
      it "admin disable and enable" do
        review = create(:review, item: @item_1)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

        visit item_review_path(@oi_1.item, review)

        click_on "Disable"

        expect(page).to have_no_link("Disable")
        expect(page).to have_link("Enable")

        click_on "Enable"

        expect(page).to have_link("Disable")
        expect(page).to have_no_link("Enable")
      end
    end

    it 'as a user I can only review an item once per order' do
      review = create(:review, item: @item_1, user: @user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_order_path(@order)

      expect(OrderItem.for_user_and_item_id(@item_1.id, @user)).to eq(1)
      expect(Review.count_by_user(@item_1.id, @user)).to eq(1)

      expect(page).to have_no_link("Review")
    end

    it 'it can see a link to see review' do
      @user.reload
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      visit profile_order_path(@order)

      within "#oitem-#{@oi_1.id}" do
        expect(page).to have_link("See ratings")
      end
    end

    it "can see a delete button" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit item_review_path(@oi_1.item, review)

      expect(page).to have_link("Delete")
    end

    it "can see a delete button" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit item_review_path(@oi_1.item, review)

      click_on "Delete"

      expect(current_path).to eq(item_reviews_path(@oi_1.item))
      expect(page).to have_content("Your review is deleted")
      expect(page).to have_no_content(review.title)
      expect(page).to have_no_content(review.description)
      expect(page).to have_no_content(review.rating)
    end

    it "can see a delete button" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit item_review_path(@oi_1.item, review)

      click_on "Delete"

      expect(current_path).to eq(item_reviews_path(@oi_1.item))
      expect(page).to have_content("Your review is deleted")
      expect(page).to have_no_content(review.title)
      expect(page).to have_no_content(review.description)
      expect(page).to have_no_content(review.rating)
    end
    it "can see a edit button" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit item_review_path(@oi_1.item, review)

      expect(page).to have_link("Edit")
    end
    it "can see a edit form" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit item_review_path(@oi_1.item, review)

      click_on "Edit"

      expect(current_path).to eq(edit_item_review_path(@oi_1.item, review))

      expect(page).to have_field("Title")
      expect(page).to have_field("Description")
      expect(page).to have_field("Rating")
    end
    it "can edit review" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit edit_item_review_path(@oi_1.item, review)

      fill_in :Title, with: "Item 1"
      fill_in :Description, with: "description"
      fill_in :Rating, with: 4

      click_on "Update Review"

      expect(current_path).to eq(item_review_path(@oi_1.item, review))
      expect(page).to have_content("Item 1")
      expect(page).to have_content("description")
      expect(page).to have_content(4)
    end
    it "can edit review" do
      review = create(:review, user: @user, item: @item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit edit_item_review_path(@oi_1.item, review)

      fill_in :Title, with: ""
      fill_in :Description, with: ""
      fill_in :Rating, with: ""

      click_on "Update Review"

      expect(page).to have_content("Something went wrong")
    end
  end
end
