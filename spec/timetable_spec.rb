# frozen_string_literal: true

require_relative '../lib/timetable.rb'
require_relative '../utils/time-tools.rb'

describe Timetable do
  describe '.routes' do
    context 'given wrong stop names' do
      it 'returns error hash' do
        output = Timetable.routes('dsad', 'dsada')
        expect(output).to be_instance_of(Hash)
        expect(output).to have_key(:error)
        expect(output[:message]).to eq('Incorrect stop name')
      end
    end

    context 'given valid stop names' do
      output = Timetable.routes('szymanowskiego', 'rynek jeżycki')
      sample = output[0]
      it 'should be a proper response hash' do
        expect(output).to be_instance_of(Array)
        expect(sample).to be_instance_of(Array)
        expect(sample[0]).to include(:day, :minutes, :stop_name,
                                     :final_destination, :hour, :is_today, :journey_time, :dest, :line)
      end
      it 'should have an arrival for today or later' do
        t = Time.now
        sample.each do |part|
          p part
          expect(part[:day]).to be_between(0, 6)
          expect(part[:day]).to eq(0).or be >= t.wday
          expect(part[:minutes].to_i).to be_between(0, 60)
          expect(part[:hour].to_i).to be_between(0, 23)
          if t.wday == part[:day].to_i
            expect(part[:is_today]).to be true
          else
            expect(part[:is_today]).to be false
          end
          if t.hour < part[:hour].to_i
            expect(part[:minutes].to_i).to be < t.min
          else
            expect(part[:minutes].to_i).to be > t.min
          end
        end
      end

      it 'should start and stop at given stops' do
        start = sample[0]
        stop = sample[sample.length - 1]
        expect(start[:stop_name].downcase).to eq 'szymanowskiego'
        expect(stop[:dest].downcase).to eq 'rynek jeżycki'
      end
    end
  end

  describe '.quick_look' do
    it 'given wrong stop name' do
    end
    it 'given wrong line number' do
    end
    it 'given wrong stop name and line number' do
    end
    it 'given valid stop and line number' do
    end
  end
end
