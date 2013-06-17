This app shows the user a list of trending Twitter topics for any given country.

The user can select a country from a drop down list of countries, and a number of Twitter topics to display. The app internally converts the country name into a Yahoo "WOEId", which is a unique country code, and then uses that to query the Twitter API and retrieve a set of trending topics for that country.

This app can be compiled for iPhone and run using the XCode simulator.

Steps:

1. The app uses the geonames.org API at startup to get a list of countries to display in a drop down

2. It uses the Yahoo YQL service to get a Yahoo "WOEId" (http://developer.yahoo.com/geo/geoplanet/guide/concepts.html) for the country the user selects. The WOEId is the parameter to the Twitter trending topics API call.

3. The app uses the Twitter API to get the list of trending topics given the WOEId for the user-entered location.

4. XML and JSON responses are parsed inline.
