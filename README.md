# nyc-geocoder-api

A simple geocoder for NYC. Similar to the NYC's official [geoclient api](https://developer.cityofnewyork.us/api/geoclient-api), but with far fewer bells and whistles.

All the heavy lifting is done by:

- [@jordanderson](https://github.com/jordanderson)'s [ruby binding](https://github.com/jordanderson/nyc_geosupport) to City Planning's [geosupport](https://www1.nyc.gov/site/planning/data-maps/open-data/dwn-gde-home.page)

- Mapzen's [libpostal](https://github.com/openvenues/libpostal)

## How to use

There's only one endpoint with 3 ways to submit an address:

1) House, Street, and Borough

``` sh
curl https://geocode.nycdb.info/?house=1000&street=surf avenue&borough=brooklyn
```

2) House, Street, and Zipcode

``` sh
curl https://geocode.nycdb.info/?house=1000&street=surf avenue&zipcode=11224
```

3) Address

``` sh
curl https://geocode.nycdb.info/?address=1000 Surf Avenue Brooklyn, NY 11224
```

All of those requests return the same json object:

``` json
{
  "bbl": "3086960212",
  "latitude": 40.57436,
  "longitude": -73.978499,
  "status": "OK"
}
```

## Response format

Successful responses contains a simple JSON object with 4 fields: bbl, latitude, longitude, status.

Responses with errors have one or two fields: status and message. If present, the message field will contain information that might help you figure out what went wrong.

Example error:

This request: 
``` sh
curl https://geocode.nycdb.info/?house=1000&street=Surf%20Avenue
```

Returns this error:

``` json
{
	"status":"ERROR",
	"message":"Missing parameter: zipcode or borough"
}
```

That's it! There's no authorization and no other information provided besides bbl, latitude and longitude.

### Installation

NOTE: This has not tested on anything other Debian-based systems. As currently setup it almost certainly won't work on other OSs.

**setup geosupport and libpostal**

``` sh
make setup libpostal
```

**Install ruby gems:**

``` sh
bundle install
```

**Setup geosupport paths**

``` sh
source libgeo-paths 
```

**Run:**

``` sh
ruby app.rb
```


**Run the tests:**

``` sh
rspec test.rb
```
