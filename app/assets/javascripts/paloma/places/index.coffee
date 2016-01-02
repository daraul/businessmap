###placesController = Paloma.controller('Places')
    
placesController.prototype.index = () ->
    $(".listing").css("display", "none")
    
    $("#listings").append("<div id=\"map\" class=\"container\"><div id=\"map-canvas\"></div></div>")
    
    params = this.params
    places = this.params['places']
    
    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]
        
        bounds = new google.maps.LatLngBounds()
        
        position = undefined 
        
        markers = []
        
        for place in places 
            position = new google.maps.LatLng(place.latitude, place.longitude)
            
            bounds.extend(position)
            
            marker = new google.maps.Marker 
                position: position
                placeID: place.id 
            
            marker.addListener('click', () ->
                $.getScript "places/#{this.placeID}", () ->
                    Paloma.executeHook();
                    Paloma.engine.start();
            )
            
            markers.push marker 
            
        map = new google.maps.Map(mapContainer, 
            center: position
            zoom: 8
        )
        
        map.fitBounds(bounds)
        map.panToBounds(bounds)
        
        for marker in markers 
            marker.setMap(map)###