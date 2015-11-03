# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Add a method to the string prototype to capitalize the first letter of a String
# SO surprised javascript doesn't already have this 
String.prototype.capitalizeFirstLetter = () -> 
    this.charAt(0).toUpperCase() + this.slice(1)

$(document).ready ->
    ApplicationID = '3J0AVN6KSY'
    
    SearchOnlyApiKey = 'fde549a36ac77931bd57966851982602'
    
    client = algoliasearch(ApplicationID, SearchOnlyApiKey)
    
    index = client.initIndex('homein_places_' + window.environment)
    
    infoWindow = new google.maps.InfoWindow
    
    initializeMap = (center, zoom, bounds, callback) ->
        map = new google.maps.Map(document.getElementById('map-canvas'), 
            zoom: zoom
            center: center 
        )
        
        if bounds 
            map.fitBounds(bounds)
            map.panToBounds(bounds)
            
        callback(map)
    
    search = (query, facetFilters, numericFilters, callback) ->
        index.search(
            query, 
            {
                "numericFilters": numericFilters
                "facetFilters": facetFilters
            },
            (err, content) ->
                if err 
                    alert err 
                    return
                
                callback(content)
        )
    
    getQuery = () ->
        query = ""
        
        queryRegex = /(?:&|#)query=(\w+)(?=&)?/g 
        
        queryMatch = queryRegex.exec(location.hash)
        
        if queryMatch
            query = queryMatch[1]
        
        return query 
        
    getFacetFilters = () ->
        facetFilters = []
        
        facetFiltersRegex = /(?:&|#)(for)=(sale|rent)(?=&)?/g
        
        facetFiltersMatch = facetFiltersRegex.exec(location.hash)
        
        while facetFiltersMatch != null 
            facetFilters.push facetFiltersMatch[1] + ":" + facetFiltersMatch[2]
            facetFiltersMatch = facetFiltersRegex.exec(location.hash)
            
        return facetFilters
    
    getNumericFilters = () ->
        numericFilters = []
            
        numericFiltersRegex = /(?:&|#)(bathrooms|rooms|price)=((?:\d+)(?:-\d+)?)(?=&)?/g;
        
        numericFiltersMatch = numericFiltersRegex.exec(location.hash)
        
        while numericFiltersMatch != null 
            console.log numericFiltersMatch[2]
            if /-/.test(numericFiltersMatch[2])
                numericFilters.push numericFiltersMatch[1] + ":" + numericFiltersMatch[2].replace("-", " to ")
            else 
                numericFilters.push numericFiltersMatch[1] + "=" + numericFiltersMatch[2]
            
            numericFiltersMatch = numericFiltersRegex.exec(location.hash)
    
    getContent = (result) ->
        content = 
            "<h1><a href=\"/places/#{result.id}/\">#{result.address}</a></h1>
            <p>#{result.description.replace(/\n/, "<br />")}</p>
            <p>Rooms: #{result.rooms} Bathrooms: #{result.bathrooms}</p>
            <p>Price: $#{result.price}"
            
        if result.for == "Rent"
            content += " per month"
        
        content += "</p>"
        
        if typeof currentuser != 'undefined' && currentuser == result.user_id
            content += 
                "<a href=\"/places/#{result.id}/edit\" class=\"place-management-link\"><i class=\"fa fa-pencil\" title=\"Edit place\"></i></a>
                <a data-confirm=\"Are you sure you want to delete this place?\" rel=\"nofollow\" data-method=\"delete\" href=\"/places/#{result.id}\" class=\"place-management-link\"><i class=\"fa fa-trash-o\" title=\"Delete place\"></i></a>"
                
        
        return content 
    
    placeMarker = (center, map, draggable, content, callback) ->
        marker = new google.maps.Marker 
            position: center 
            map: map 
            draggable: draggable
            
        if content 
            marker.content = content 
            
        return marker 
        
        if callback 
            callback(marker)
    
    setLatLng = (position) ->
        $("form .field #place_latitude").val(position.lat())
        $("form .field #place_longitude").val(position.lng())
    
    reverseGeocode = (position, callback) ->
        geocoder = new google.maps.Geocoder()
        
        $("form .field #place_address").attr("disabled", "disabled")
        
        geocoder.geocode( { 'latLng' : position }, (results, status) ->
            $("form .field #place_address").removeAttr("disabled")
            $("form .field #place_address").val(results[0].formatted_address)
        )
        
    getPosition = (callback) ->
        if navigator.geolocation 
            navigator.geolocation.getCurrentPosition((result) ->
                position = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)
                callback(position)
            , () ->
                position = new google.maps.LatLng(37.0625,-95.677068)
                callback(position) 
            )
    
    decodeURL = () ->
        if /^\/(places)?\/?$/.test(location.pathname)
            search(getQuery(), getFacetFilters(), getNumericFilters(), (content) ->
                bounds = new google.maps.LatLngBounds()
                
                markers = []
                
                results = content.hits 
                
                for result in results 
                    position = new google.maps.LatLng(result.latitude, result.longitude)
                    
                    bounds.extend(position)
                
                center = bounds.getCenter()
                initializeMap(center, 1, bounds, (map) ->  #Set an arbitrary zoom level to initialize the map, then zoom, pan to bounds 
                    for result in results 
                        position = new google.maps.LatLng(result.latitude, result.longitude)
                        
                        marker = placeMarker(position, map, false, getContent(result))
                        
                        marker.title = result.description 
                        
                        marker.addListener('click', () ->
                            infoWindow.setContent(this.content)
                            infoWindow.open(map, this) 
                        )
                            
                        markers.push marker 
                    
                    markerClusterer = new MarkerClusterer(map, markers)
                )
            )
        else if /^\/places\/\d+\/?$/.test(location.pathname)
            place = window.place
            window.place = undefined 
            
            center = new google.maps.LatLng(place.latitude, place.longitude)
            
            initializeMap(center, 14, null, (map) ->
                marker = placeMarker(center, map, false, getContent(place))
                
                infoWindow.setContent(marker.content)
                infoWindow.open(map, marker)
                
                marker.addListener('click', () ->
                    infoWindow.open(map, marker)
                )
            )
        else if /^\/places\/\d+\/edit\/?$/.test(location.pathname)
            form = window.form 
            window.form = undefined 
            
            place = window.place 
            window.place = undefined 
            
            center = new google.maps.LatLng(place.latitude, place.longitude)
            
            initializeMap(center, 14, null, (map) ->
                marker = placeMarker(center, map, true)
                    
                infoWindow.setContent(form)
                infoWindow.open(map, marker)
                
                marker.addListener('click', () ->
                    infoWindow.open(map, marker)
                    setLatLng(marker.position)
                    reverseGeocode(marker.position)
                ) 
                
                marker.addListener('dragend', () ->
                    setLatLng(marker.position)
                    reverseGeocode(marker.position)
                ) 
            )
        else if /^\/places\/new\/?$/.test(location.pathname)
            form = window.form 
            window.form = undefined 
            
            getPosition((position) ->
                initializeMap(position, 14, undefined, (map) ->
                    marker = placeMarker(position, map, true)
                    
                    marker.addListener('click', () ->
                        infoWindow.open(map, marker)
                        setLatLng(marker.position)
                        reverseGeocode(marker.position)
                    ) 
                    
                    marker.addListener('dragend', () ->
                        setLatLng(marker.position)
                        reverseGeocode(marker.position)
                    ) 
                
                    infoWindow.setContent(form)
                    infoWindow.open(map, marker)
                )
            )
        else if /^\/you\/?$/.test(location.pathname)
            places = window.places 
            window.places = undefined
            
            bounds = new google.maps.LatLngBounds()
            
            markers = []
            
            for place in places 
                position = new google.maps.LatLng(place.latitude, place.longitude)
                
                bounds.extend(position)
                
            center = bounds.getCenter()
            
            initializeMap(center, 1, bounds, (map) ->  #Set an arbitrary zoom level to initialize the map, then zoom, pan to bounds 
                for place in places
                    position = new google.maps.LatLng(place.latitude, place.longitude)
                    
                    marker = placeMarker(position, map, false, getContent(place))
                    
                    marker.title = place.description 
                    
                    marker.addListener('click', () ->
                        infoWindow.setContent(this.content)
                        infoWindow.open(map, this) 
                    )
                
                    markers.push marker 
                
                markerClusterer = new MarkerClusterer(map, markers)
            )
            
    decodeURL()