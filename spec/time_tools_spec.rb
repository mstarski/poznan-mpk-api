# frozen_string_literal: true

require_relative '../utils/time-tools.rb'

describe TimeTools do
  context 'given minutes that will not change the hour' do
    it 'should add minutes properly' do
      sample_time = [10, 1]
      result = TimeTools.add_minutes(sample_time, 19)
      expect(result).to include(10, 20)
    end
  end

  context 'given minutes that will change the hour' do
    it 'should add minutes properly and return valid time' do
      sample_time = [10, 59]
      result = TimeTools.add_minutes(sample_time, 23)
      expect(result).to include(11, 22)
    end
  end
end



