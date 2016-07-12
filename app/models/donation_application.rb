class DonationApplication < ActiveRecord::Base
  belongs_to :applicant, class_name: "User", foreign_key: "user_id"
  belongs_to :listing

  # def export_pdf
  #   user = self.applicant
  #   contact = user.contact_infos.find_by(email: self.email)
  #   pdf_form = DonationApplicationPdf.new(user: user, contact: contact, listing: self.listing).export
  #   send_file(pdf_form, type: 'application/pdf')
  # end

  # def display_pdf
  #   user = self.applicant
  #   contact = user.contact_infos.find_by(email: self.email)
  #   pdf_form = DonationApplicationPdf.new(user: user, contact: contact, listing: self.listing).export
  #   send_file(pdf_form, disposition: 'inline', type: 'application/pdf')
  # end

end
