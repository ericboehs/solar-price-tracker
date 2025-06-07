class WatchesController < ApplicationController
  before_action :set_watch, only: [ :show, :edit, :update, :destroy ]

  def index
    @watches = Watch.includes(:watchable).order(:name)
    @search_watches = @watches.searches
    @product_watches = @watches.product_watches
  end

  def show
  end

  def new
    @watch = Watch.new
  end

  def create
    @watch = Watch.new(watch_params)

    if @watch.save
      redirect_to @watch, notice: "Watch was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @watch.update(watch_params)
      redirect_to @watch, notice: "Watch was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @watch.destroy
    redirect_to watches_path, notice: "Watch was successfully deleted."
  end

  private

  def set_watch
    @watch = Watch.find(params[:id])
  end

  def watch_params
    params.require(:watch).permit(:name, :description, :url, :omit_list, :exclude_bundles, :active, :watchable_id, :watchable_type)
  end
end
