module TimeTools
    #time: <Array<int, int>> - [hours, minutes]
    #minutes: int - minutes to add
    def TimeTools::add_minutes(time, minutes)
        mins_total = time[1] + minutes
        extra_hours = mins_total / 60
        minutes_remainder = mins_total % 60
        return [time[0] + extra_hours, minutes_remainder]
    end
end
