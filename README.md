# Poznań MPK API

The api scrapps [Poznań City communication webpage](http://www.mpk.poznan.pl) to provide trams' departure times and route planning.

## Getting started

There are two ways to run poznan-mpk-api.
The first and the easiest one is to run the app using **your ruby binary**: 

Start by installing necessary dependencies

```shell
	$ bundle install
```

App requires data scrapped from the [MPK Poznań's page](http://www.mpk.poznan.pl).
To run the scrapper type:

```shell
	$ make scrap
```

and wait until scrapping process is done (it takes around 10-15s depending on your internet connection).

Finally you can run the app by typing:

```shell
	$ rackup -p <port>
```

The second way requires **docker** installed on your machine.
It will run an app inside a container, ensuring that everything will work correctly.
To run the app inside a docker container type:

```shell
	$ make start
```

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

Each array holds a route that can be taken to reach the destination. <br>

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

Displays nearest arrival for given stop and line number.

**Request body**

```
{
	stop: <String>,
	line: <Int>
}
```

Stop must be a valid MPK Poznań (Tram) stop name.<br>
Line must be a valid number of a MPK Poznań tram.

**Example response body**

```json
[
	{
		"day": 2,
		"minutes": "27oN",
		"stop_name": "Szymanowskiego",
		"final_destination": "Franowo",
		"hour": 21,
		"is_today": true,
		"line": "16"
	},
	{
		"day": 2,
		"minutes": "23N",
		"stop_name": "Szymanowskiego",
		"final_destination": "Os. Sobieskiego",
		"hour": 21,
		"is_today": true,
		"line": "16"
	}
]
```

Each object represents the nearest arrival of the given tram. <br>

```
day: [0-6] - Day number where 0 is Sunday
minutes: [0-60N?] - Minutes of departure
stop_name: string - Stop name
final_destination: string - line's final destination (direction of the tram)
hour: [0-24] - Hour of departure
is_today: true|false - Is the departure today
line: int - Line number
```

## Testing

You can run tests simply by typing:
```bash
$ make test
```
**To run tests you have to have your data already scrapped.**
