class DonationApplication < ActiveRecord::Base
  belongs_to :applicant, class_name: "User", foreign_key: "user_id"
  belongs_to :listing

  def export_pdf
    user = self.applicant
    contact = ContactInfo.new(
      first_name: self.first_name,
      last_name: self.last_name,
      title: self.title,
      email: self.email,
      phone: self.phone,
      fax: self.fax,
    )

    DonationApplicationPdf.new(
      user: user,
      contact: contact,
      listing: self.listing).export
  end
end
