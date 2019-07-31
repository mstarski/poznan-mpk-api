# Poznan MPK API

The api scrapps [Poznań City communication webpage](http://www.mpk.poznan.pl) to provide trams' departure times and route planning.

## API Reference

`POST /api/get_routes` - Displays possible routes to take between two stops

Request body:

```
    {
        from: <String>
        to: <String>
    }
```

Both from and to must be a valid MPK Poznań (Tram) stop name.

Example response body: 
```
    
```
