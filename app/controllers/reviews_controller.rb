class ReviewsController < ApplicationController

  def new
    @item = Item.find(params[:item_id])
    @order = Order.where(id: params[:order_id]).first
    @review = Review.new
  end

  def show
    @review = Review.find(params[:id])
  end

  def create
    @item = Item.find(params[:item_id])
    @review = @item.reviews.build(review_params)
    @review.user = current_user || current_admin?
    if @review.save
      redirect_to item_review_path(@item, @review)
    else
      render :new
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating)
  end

end
