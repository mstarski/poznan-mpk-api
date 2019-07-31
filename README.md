# Poznan MPK API

The api scrapps [Poznań City communication webpage](http://www.mpk.poznan.pl) to provide trams' departure times and route planning.

## API Reference

`POST /api/get_routes`<br>
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
	[    {

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

Each array holds a route that can be taken to reach the destination
