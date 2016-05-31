class SpreadsheetParser
  require 'roo'
  require 'roo-xls'

  FILETYPE_WHITELIST = %w(csv xls xlsx xlsm ods)

  VALID_HEADERS = {
    listing: ["title", "description", "fair_market_value", "image_url"]
  }

  def initialize(attributes = {})
    @original_file = attributes[:file]
    @import_type = attributes[:import_type].downcase.to_sym
    @parsed_file = convert_file
  end

  def rows
    parsed_rows = []
    header_cols = get_header_index

    @parsed_file.each do |row|
      record = {}

      header_cols.each do |k, v|
        record[k] = row[v]
      end
      parsed_rows << record
    end
    parsed_rows.shift # exclude header row

    parsed_rows
  end

  private

  def get_header_index
    header_index = {}

    VALID_HEADERS[@import_type].each do |header|
      col = @parsed_file.row(1).index(header)
      header_index[header.to_sym] = col if col
    end

    header_index
  end

  def convert_file
    return false unless valid_filetype?
    @parsed_file = Roo::Spreadsheet.open(@original_file)
    @parsed_file
  end

  def valid_filetype?
    basename, dot, ext = @original_file.original_filename.rpartition(".")
    FILETYPE_WHITELIST.include?(ext)
  end
end
