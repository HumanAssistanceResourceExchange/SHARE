class DonationApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @listing = set_listing
    @contact = ContactInfo.find(params[:contact])
    submission_status ||= "printed" if @listing.requires_pdf_form?
    submission_status ||= "emailed"
    phone = @contact.phone
    phone += (" ext: " + @contact.extension) if @contact.extension
    donation_application = DonationApplication.new(
      applicant: current_user,
      listing: @listing,
      first_name: @contact.first_name,
      last_name: @contact.last_name,
      title: @contact.title,
      email: @contact.email,
      phone: phone,
      fax: @contact.fax,
      submission_status: submission_status
      )

    if donation_application.save
      unless @listing.followers.include?(current_user)
        @listing.followers << current_user
      end
      # Mailer send
      if @listing.requires_pdf_form?
        download_pdf and return
      else
        donation_application.update(submission_date: Time.now)
      end
      flash[:success] = "Your application has been #{submission_status}!"
      DonationApplicationMailer.donation_request(@listing, current_user).deliver_now
      DonationApplicationMailer.donation_requested(@listing, current_user).deliver_now
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end

    redirect_to listing_path(@listing)
  end

  def show
    display_pdf
  end

  def update_mailed_submission
    listing = set_listing
    applicant = current_user
    donation_application = get_donation_application(applicant: applicant, listing: listing)

    if donation_application.update(submission_status: "mailed", submission_date: Time.now)
      flash[:success] = "Your submission status has been updated"
      DonationApplicationMailer.donation_pdf_mailed(listing, current_user).deliver_now
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end

    redirect_to listing_path(listing)
  end


  def approve_applicant
    listing = set_listing
    applicant = User.find(params[:id])
    donation_application = get_donation_application(applicant: applicant, listing: listing)

    if donation_application.update(approval_status: "approved")
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  def decline_applicant
    listing = set_listing
    applicant = User.find(params[:id])
    donation_application = get_donation_application(applicant: applicant, listing: listing)

    if donation_application.update(approval_status: "declined")
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  def reset_applicant
    listing = set_listing
    applicant = User.find(params[:id])
    donation_application = get_donation_application(applicant: applicant, listing: listing)

    if donation_application.update(approval_status: nil)
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  private
  def get_donation_application(args = {})
    applicant = args[:applicant]
    listing = args[:listing]
    listing.donation_applications.find_by(applicant: applicant)
  end

  def set_listing
    Listing.find(params[:listing_id])
  end

  def export_pdf
    DonationApplicationPdf.new(user: current_user, contact: @contact, listing: @listing).export
  end

  def download_pdf
    send_file(export_pdf, type: 'application/pdf')
  end

  def display_pdf
    send_file(export_pdf, disposition: 'inline', type: 'application/pdf')
  end

  def donation_application_params
    params.require(:donation_application).permit(:submission_status, :submission_date, :approval_status, :approval_status_reason, :contact)
  end
end
