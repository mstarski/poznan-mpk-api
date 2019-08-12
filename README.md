# Poznan MPK API

The api scrapps [Poznań City communication webpage](http://www.mpk.poznan.pl) to provide trams' departure times and route planning.

## API Reference

### GET `/api/get_routes`

Displays possible routes to take between two stops

**Request body**:

```
    {
        from: <String>
        to: <String>
    }
```

Both from and to must be a valid MPK Poznań (Tram) stop name.

**Example response body**:

```json
[
	[
		{
			"day": 3,
			"hour": 12,
			"minutes": "46N",
			"is_today": true,
			"stop_name": "Arciszewskiego",
			"journey_time": 3,
			"dest": "Rondo Nowaka-Jeziorańskiego",
			"line": "7"
		}
	],
	[
		{
			"day": 3,
			"hour": 12,
			"minutes": "57N",
			"is_today": true,
			"stop_name": "Arciszewskiego",
			"journey_time": 3,
			"dest": "Rondo Nowaka-Jeziorańskiego",
			"line": "1"
		}
	],
	[
		{
			"day": 3,
			"hour": 12,
			"minutes": "56",
			"is_today": true,
			"stop_name": "Arciszewskiego",
			"journey_time": 3,
			"dest": "Rondo Nowaka-Jeziorańskiego",
			"line": "8"
		}
	]
]
```

Each array holds a route that can be taken to reach the destination <br>

```
day: [0-6] - Day number where 0 is Sunday
hour: [0-24] - Hour of departure
minutes: [0-60N?] - Minutes of departure
is_today: true|false - Is the departure today
stop_name: string - Stop name
journey_time: int - Journey time in minutes
dest: string - Destination stop name
line: int - Line number
```

### GET `/api/quick_look`

Displays nearest arrival for given stop and line number

**Request body**

```
{
	stop: <String>,
	line: <Int>
}
```

Stop must be a valid MPK Poznań (Tram) stop name.
Line must be a valid number of a MPK Poznań tram.
