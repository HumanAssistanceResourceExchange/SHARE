class ListingsController < ApplicationController
  include ListingsHelper
  include UsersHelper
  include DonationApplicationsHelper
  before_action :authenticate_user!, except: [:index, :show]

  def new
    @listing = Listing.new
  end

  def create
    @listing = Listing.new(listing_params.merge! creator: current_user)

    if @listing.save
      @listing.categories << Category.find(params[:listing][:category_ids])
      redirect_to listings_path, :notice => "Your listing has been saved"
    else
      redirect_to new_listing_path, :notice => "Your listing could not be created. Make sure all fields are filled out and try again."
    end
  end

  def index
    session.delete(:listings_index)
    @categories = Category.all.to_a
    @category_filters = []
    @page_title = "Available Donations"
    @listings = Listing.order(created_at: :desc)
  end

  def show
    set_listings_index
    @listing = Listing.find(params[:id])
    if current_user
      @application_submission = current_user.donation_applications.find_by(listing: @listing)
      applications = DonationApplication.includes(:applicant).where(listing: @listing).order(submission_date: :asc, created_at: :asc).reject { |da| da.submission_date.nil? }

      @applications_received = applications.map do | application |
        { tracker: application,
          applicant: get_applicant_info(application.applicant) }
      end
    end
  end

  def edit
    @listing = Listing.find(params[:id])
  end

  def update
    @listing = Listing.find(params[:id])
    if @listing.update_attributes(listing_params)
        redirect_to listing_path, :notice => "Your listing has been updated"
    else
      redirect_to edit_listing_path, :notice => "Your listing could not be updated. Make sure all fields are filled out and try again."
    end
  end

  def donation_history
    @listings = Listing.where(creator: current_user).to_a
    @page_title = "My Donations"
    render 'listings/index'
  end

  def request_history
    donation_applications = current_user.donation_applications.to_a
    @listings = donation_applications.map { |l| l = l.listing }
    @page_title = "My Requests"
    render 'listings/index'
  end

  def follow_history
    followed_listings = current_user.followed_listings.to_a
    @listings = followed_listings.map { |l| l = l.listing }
    @page_title = "My Watched Listings"
    render 'listings/index'
  end

  def destroy
    Listing.destroy(params[:id])
    redirect_to user_donations_path, :notice => "Your listing has been removed."
  end

  def follow
    listing_id = params[:id]
    unless view_context.is_followed? listing_id
      watchlist = current_user.followed_listings.build(listing_id: listing_id).save
      redirect_to :back
    end
  end

  def unfollow
    listing_id = params[:id]
    if view_context.is_followed? listing_id
      follow_id = current_user.followed_listings.where(listing_id: listing_id).first.id
      current_user.followed_listings.delete(follow_id)
      redirect_to :back
    end
  end

  def new_import
    #
  end

  def import
    Listing.import(params[:file])
    redirect_to listings_path, :notice => "Your listings have been imported"
  end

  private

  def set_listings_index(default = listings_path )
    prev_page = request.env["HTTP_REFERER"]
    if prev_page.present? && prev_page.include?("browse")
      session[:listings_index] ||= prev_page
    else
      session[:listings_index] ||= default
    end
  end

  def get_applicant_info(applicant, options = {})
    user = applicant || User.find(options[:user_id])
    contact ||= options[:contact]
    contact ||= user.contact_infos.find(options[:contact_info_id]) if options[:contact_info_id]
    contact ||= user.contact_infos.find_by(primary: true) || user.contact_infos.first
    address ||= options[:address]
    address ||= user.addresses.find(options[:address_id]) if options[:address_id]
    address ||= user.addresses.find_by(primary: true) || user.addresses.first

    applicant = {}
    applicant[:info] = contact ? contact.attributes : {}
    applicant[:info].merge! address ? address.attributes : {}
    applicant[:info].transform_keys! { |k| k.to_sym }

    applicant
  end

  def listing_params
   params.require(:listing).permit(:id, :title, :description, :fair_market_value, :image_url)
  end
end
