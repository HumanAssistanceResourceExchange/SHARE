# class DonationAppPdfsController < ApplicationController
#   before_action :pdf_params
#   before_action :get_listing
#   before_action :get_user

#   def show
#     respond_to do |format|
#       format.html
#       format.pdf { send_file DonationApplicationPdf.new(user: @user, listing: @listing).export, type: 'application/pdf' }
#     end
#   end

#   protected

#     def get_listing
#       @listing = Listing.find(params[:id])
#     end

#     def get_user
#       @user = current_user
#     end

#     def pdf_params
#       @pdf_params = params.require(:listing).permit(:id)
#     end
# end
