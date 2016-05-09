class Importer
  include ActiveModel::Validations
  include ActiveModel::Conversion

  VALID_IMPORT_TYPES = ['listing']

  validates :import_type, inclusion: { in: VALID_IMPORT_TYPES }
  attr_reader :parser, :import_type
  attr_accessor :records_created, :errors

  def initialize(attributes = {})
    @creator = attributes[:creator]
    @parser = attributes[:parser]
    @import_type = attributes[:import_type]
    @records_created = 0
    @errors = []
  end

  def import
    if valid?
      rows.each do |row|
        row.merge!({ creator: @creator })
        row_err = row.delete(:errors)
        if row_err
          @errors << row_err
        else
          new_record = import_factory.new(row)
          @records_created += 1 if new_record.save
        end
      end
      true
    else
      false
    end
  end

  private

  def rows
    # expects array of hashes
    # each hash key corresponds to import type's AR attributes
    @parser.rows
  end

  def import_factory
    @import_type.to_s.titleize.constantize
  end
end
