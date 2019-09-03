# frozen_string_literal: true

require_relative '../lib/find_routes.rb'
require 'pp'

describe FindRoute do
  describe '.route' do
    context 'given wrong stop names' do
      it 'returns -1' do
        expect(FindRoute.route('dsad', 'dasda')).to eql(-1)
      end
    end
    context 'given proper stop names' do
      it 'returns array of routes' do
        result = FindRoute.route('os. piastowskie', 'szymanowskiego')
        expect(result).to be_kind_of(Array)
        expect(result).to include(a_kind_of(Array))
      end
    end
  end
end
