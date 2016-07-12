class DonationApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing
  before_action :set_contact, only: [:create, :get_pdf]
  before_action :set_donation_application, except: [:create]

  def create
    @listing = Listing.find(params[:listing_id])
    submission_status ||= "printed" if @listing.requires_pdf_form?
    submission_status ||= "emailed"
    phone = @contact.phone
    phone += (" ext: " + @contact.extension) if @contact.extension
    @donation_application = DonationApplication.new(
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

    if @donation_application.save
      unless @listing.followers.include?(current_user)
        @listing.followers << current_user
      end
      # Mailer send
      if @listing.requires_pdf_form?
        export_pdf and return
      else
        @donation_application.update(submission_date: Time.now)
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
    listing = Listing.find(params[:listing_id])

    if @donation_application.update_attributes(submission_status: "mailed", submission_date: Time.now)
      flash[:success] = "Your submission status has been updated"
      DonationApplicationMailer.donation_pdf_mailed(listing, current_user).deliver_now
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end

    redirect_to listing_path(listing)
  end


  def approve_applicant
    listing = Listing.find(params[:listing_id])

    if @donation_application.update_attributes(approval_status: "approved")
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  def decline_applicant
    listing = Listing.find(params[:listing_id])

    if @donation_application.update_attributes(approval_status: "declined")
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  def reset_applicant
    listing = Listing.find(params[:listing_id])

    if @donation_application.update_attributes(approval_status: nil)
      flash[:success] = "Application status has been updated for #{donation_application.applicant.email}"
    else
      flash[:danger] = "Your request was unsuccessful, please try again"
    end
    redirect_to listing_path(listing)
  end

  private
  def set_donation_application
    @donation_application = current_user.donation_applications.find_by(listing: @listing)
  end

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def set_contact
    @contact = ContactInfo.find(params[:contact])
  end

  def get_pdf
    DonationApplicationPdf.new(user: current_user, contact: @contact, listing: @listing).export
  end

  def export_pdf
    send_file(get_pdf, type: 'application/pdf')
  end

  def display_pdf
    send_file(get_pdf, disposition: 'inline', type: 'application/pdf')
  end

  def donation_application_params
    params.require(:donation_application).permit(:submission_status, :submission_date, :approval_status, :approval_status_reason, :contact)
  end
end
