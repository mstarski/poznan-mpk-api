# frozen_string_literal: true

require_relative '../lib/scrapper.rb'
require 'json'
require 'fileutils'

RSpec.configure do |config|
  config.after(:suite) do
    FileUtils.rm_r(File.join(__dir__, 'tmp'))
  end
end

RSpec.describe Scrapper do
  it 'Should properly scrap all the needed data to the file' do
    Scrapper.scrap_data('spec/tmp', false)
    expect(File.file?(File.join(__dir__, 'tmp', 'ztm_data.json'))).to be(true)
    file = File.read(File.join(__dir__, 'tmp', 'ztm_data.json'))
    file_json = JSON.parse(file)
    expect(file_json).to be_instance_of(Hash)
  end
end
