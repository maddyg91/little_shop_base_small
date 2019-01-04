class ReviewsController < ApplicationController

  def new
    @item = Item.find(params[:item_id])
    @review = Review.new
  end

  def create

    @item = Item.find(params[:item_id])
    @order = Order.joins(:reviews).where("user_id = reviews.user_id")
    @review = @item.reviews
    if @review.save
      redirect_to profile_order_path(@order)
    else
      render :new
    end
  end

end
