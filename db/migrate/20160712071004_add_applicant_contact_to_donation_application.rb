class AddApplicantContactToDonationApplication < ActiveRecord::Migration
  def change
    change_table :donation_applications do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :phone
      t.string :fax
      t.string :address
      t.string :city
      t.string :state_zip
      t.string :website
      t.string :email
    end
  end
end
