class ReviewsController < ApplicationController
  before_action :require_current_user

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
    @review = @item.reviews.new(review_params)
    @review.user = current_user
    if @review.save
      redirect_to item_review_path(@item, @review)
    else
      render :new
    end
  end

  def edit
    @item = Item.find(params[:item_id])
    @review = Review.find(params[:id])
  end

  def update
    @item = Item.find(params[:item_id])
    @review = Review.find(params[:id])
    if current_user
      if @review.update(review_params)
        flash[:success] = "Review was updated"
        redirect_to item_review_path(params[:item_id], params[:id])
      else
        flash[:error] = "Something went wrong"
        render :edit
      end
    end
  end

  def disable_enable
   @item = Item.find(params[:item_id])
   @review = Review.find(params[:id])
   if disabling_reviewer? || current_admin?
     if @review.update(review_params)
       flash[:success] = "Success"
     else
       flash[:error] = "Update failed"
     end
   end
    redirect_to item_review_path(params[:item_id], params[:id])
  end

  def destroy
    @item = Item.find(params[:item_id])
    @review = Review.find(params[:id])
    if reviewer? || current_admin?
      if @review.destroy
        flash[:success] = "Your review is deleted"
      else
        flash[:error] = "Failed to delete"
      end
      redirect_to item_reviews_path(params[:item_id])
    else
      render file: 'errors/not_found'
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating, :active)
  end

  def disabling_reviewer?
    reviewer? && params[:review] && params[:review][:active] == "false"
  end

  def reviewer?
    current_user.id == @review.user_id
  end

end
