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
      it 'returns proper response hash' do
        output = Timetable.routes('szymanowskiego', 'rynek jeżycki')
        expect(output).to be_instance_of(Array)
        sample = output[0]
        expect(sample).to be_instance_of(Array)
        expect(sample[0]).to include(:day, :minutes, :stop_name,
                                  :final_destination, :hour, :is_today, :journey_time, :dest, :line)
      end
    end
  end
end
