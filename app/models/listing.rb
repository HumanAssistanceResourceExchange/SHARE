class Listing < ActiveRecord::Base
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  has_many :followed_listings, dependent: :destroy
  has_many :followers, through: :followed_listings
  has_many :listings_categories, dependent: :destroy
  has_many :categories, through: :listings_categories
  has_many :donation_applications, dependent: :destroy
  has_many :applicants, through: :donation_applications

  def get_show_image
    self.image_url || 'http://placehold.it/400x300&text=[img]'
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      logger.debug "ROW: #{row}"
      listing = find_by_id(row['id']) || new
      listing.attributes = row.to_hash
      logger.debug "LISTING: #{listing}"
      listing.save!
    end
  end

  def requires_pdf_form?
    # !self.pdf.nil?
    self.creator.entity_name == "Sacramento County"
  end
end
