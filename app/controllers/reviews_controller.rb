class ReviewsController < ApplicationController

  def index
    @item = Item.find(params[:item_id])
    @reviews = @item.reviews
  end

  def new
    @item = Item.find(params[:item_id])
    @order = Order.where(id: params[:order_id]).first
    @review = Review.new
  end

  def show
    @item = Item.find(params[:item_id])
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

  def update
   @review = Review.find(params[:id])
   if current_user.id == @review.user_id || current_admin?
     if @review.update(review_params)
       redirect_to item_reviews_path(params[:item_id], params[:id])
     else
       flash[:error] = "Update failed"
       redirect_to item_reviews_path(params[:item_id], params[:id])
     end
   else
   end
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating, :active)
  end

end
