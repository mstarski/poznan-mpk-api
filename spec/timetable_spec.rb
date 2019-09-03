# frozen_string_literal: true

require_relative '../lib/timetable.rb'

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

      it 'have got a valid time' do
        t = Time.now
        sample.each do |part|
          expect(part[:day]).to be_between(0, 6)
          expect(part[:day]).to eq(0).or be >= t.wday
          expect(part[:minutes].to_i).to be_between(0, 60)
          expect(part[:hour].to_i).to be_between(0, 23)
          if t.wday == part[:day].to_i
            expect(part[:is_today]).to be true
          else
            expect(part[:is_today]).to be false
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
    context 'given wrong stop name' do
      output = Timetable.quick_look(12, 'dasdads')
      it 'returns an empty array' do
        expect(output).to be_empty
      end
    end

    context 'given wrong line number' do
      output = Timetable.quick_look(111, 'os. piastowskie')
      it 'returns an empty array' do
        expect(output).to be_empty
      end
    end

    context 'given wrong stop name and line number' do
      output = Timetable.quick_look(111, 'dasdasd')
      it 'returns an empty array' do
        expect(output).to be_empty
      end
    end

    context 'given valid stop and line number' do
      output = Timetable.quick_look(12, 'os. piastowskie')
      it 'has two elements one per direction' do
        expect(output).to be_instance_of(Array)
        expect(output.length).to eq(2)
      end

      it 'has all the defined keys as well as points to the correct stop and line' do
        output.each do |entry|
          expect(entry.keys).to include(:day, :minutes, :stop_name, :final_destination,
                                        :hour, :is_today, :line)
          expect(entry[:stop_name].downcase).to eq 'os. piastowskie'
          expect(entry[:line].to_i).to eq 12
        end
      end
    end

    context 'given the stop is the last one on the route' do
      output = Timetable.quick_look(16, 'os. sobieskiego')
      it 'should have only one entry' do
        expect(output.length).to eq 1
      end
    end
  end
end
