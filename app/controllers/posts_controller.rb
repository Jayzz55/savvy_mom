class PostsController < ApplicationController
  def index
    @posts = Post.all.paginate(:page => params[:page], :per_page => 20)
    @posts = @posts.where("saving >= ?", params["min_saving"].to_i) if params["min_saving"].present?
    @posts = @posts.where("saving_percentage >= ?", params["min_saving_percentage"].to_i) if params["min_saving_percentage"].present?
    @posts = @posts.where(catalogue_id: Catalogue.find_by(shop:params["coles"]).id) if params["coles"].present? && !(params["woolworths"].present?)
    @posts = @posts.where(catalogue_id: Catalogue.find_by(shop:params["woolworths"]).id) if params["woolworths"].present? && !(params["coles"].present?)
    @posts = @posts.where(catalogue_id: Catalogue.find_by(date:params["period"]).id) if params["period"].present?
  end
end