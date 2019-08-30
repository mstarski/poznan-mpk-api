# frozen_string_literal: true

require 'json'
# Gives access to the scrapped ztm data
module ZtmModel
  ZTM_DATA = JSON.load(File.new("#{__dir__}/../data/ztm_data.json"))

  STOPS_DATA = ZTM_DATA['stops_data']
  WORKING_LINE_NUMBERS = ZTM_DATA['working_line_numbers']
end
