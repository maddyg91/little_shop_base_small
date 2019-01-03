class ReviewsController < ApplicationController

  def new
    @item = Item.find(params[:item_id])
    @review = Review.new
  end

  def create

  end

end
