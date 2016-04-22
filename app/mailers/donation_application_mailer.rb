class DonationApplicationMailer < ApplicationMailer

  def donation_request(listing, donee_user)
    @listing = Listing.find(listing.id)
    @donor = User.find(@listing.user_id)
    @donee = donee_user

    subject = 'Request Submitted for Listing "' + @listing.title + '" (ID #' + @listing.id.to_s + ')'

    mail(to: @donor.email, subject: subject)
  end

  def donation_requested(listing, donee_user)
    @listing = Listing.find(listing.id)
    @donor = User.find(@listing.user_id)
    @donee = donee_user

    subject = 'Your Request for "' + @listing.title + '" (ID #' + @listing.id.to_s + ') Has Been Submitted'

    mail(to: @donee.email, subject: subject)
  end

  def donation_pdf_mailed(listing, donee_user)
    @listing = Listing.find(listing.id)
    @donor = User.find(@listing.user_id)
    @donee = donee_user

    subject = 'Sac County Donation Request Form Mailed'

    mail(to: @donor.email, subject: subject)
  end

  private
  def listing_params
    params.require(:listing).permit([:id])
  end
end
