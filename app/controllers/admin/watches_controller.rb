class Admin::WatchesController < ApplicationController
  before_action :require_admin
  before_action :set_watch, only: [ :show, :edit, :update, :destroy, :scrape ]

  def index
    @watches = Watch.all.order(created_at: :desc)
    @watch_stats = {
      total: @watches.count,
      active: @watches.active.count,
      inactive: @watches.inactive.count,
      ready_for_scraping: @watches.ready_for_scraping.count
    }
  end

  def show
  end

  def new
    @watch = Watch.new
  end

  def create
    @watch = Watch.new(watch_params)

    if @watch.save
      redirect_to admin_watch_path(@watch), notice: "Watch was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @watch.update(watch_params)
      redirect_to admin_watch_path(@watch), notice: "Watch was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @watch.destroy
    redirect_to admin_watches_path, notice: "Watch was successfully deleted."
  end

  def scrape
    ProcessWatchJob.perform_later(@watch)
    redirect_to admin_watch_path(@watch), notice: "Scraping job queued for this watch."
  end

  private

  def set_watch
    @watch = Watch.find(params[:id])
  end

  def watch_params
    params.require(:watch).permit(:name, :url, :watch_type, :description, :active,
                                  :exclude_bundles, :omit_terms)
  end

  def require_admin
    redirect_to root_path unless admin?
  end
end
