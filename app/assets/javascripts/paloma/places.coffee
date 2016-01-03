placesController = Paloma.controller('Places')
    
placesController.prototype.index = () ->
    $(".listing").css("display", "none")
    
    $("#listings").append("<div id=\"map\" class=\"container\"><div id=\"map-canvas\"></div></div>")

    places = this.params['places']
    
    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]
        
        bounds = new google.maps.LatLngBounds()
        
        position = undefined 
        
        markers = []

        infoWindow = new google.maps.InfoWindow
        
        for place in places 
            position = new google.maps.LatLng(place.latitude, place.longitude)
            
            bounds.extend(position)
            
            marker = new google.maps.Marker 
                position: position
                placeID: place.id 
            
            marker.addListener('click', () ->
                infoWindow.close()

                $.getScript "places/#{this.placeID}", (response) ->
                    infoWindow.setContent(response.replace(/[\\n"]/g, ""))

                infoWindow.open(map, this)
            )

            markers.push marker 
            
        map = new google.maps.Map(mapContainer, 
            center: position
            zoom: 8
        )
        
        map.fitBounds(bounds)
        map.panToBounds(bounds)
        
        for marker in markers 
            marker.setMap(map)

placesController.prototype.show = () ->
    place = this.params['place']

    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]

        position = new google.maps.LatLng(place.latitude, place.longitude)

        map = new google.maps.Map(mapContainer, 
            center: position
            zoom: 8
        )

        marker = new google.maps.Marker 
            position: position
            map: map 

placesController.prototype.edit = () ->
    place = this.params['place']

    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]

        position = new google.maps.LatLng(place.latitude, place.longitude)

        map = new google.maps.Map(mapContainer, 
            center: position
            zoom: 8
        )

        marker = new google.maps.Marker 
            position: position
            map: map 
            draggable: true 

        geocoder = new google.maps.Geocoder()

        marker.addListener('dragend', () ->
            $("#place_latitude").val(this.position.lat())
            $("#place_longitude").val(this.position.lng())
            
            $("#place_address").attr("disabled", "disabled")
            
            geocoder.geocode( { 'latLng' : this.position }, (results, status) ->
                $("#place_address").removeAttr("disabled")

                if results[0] == undefined
                    alert "No address found! Please enter one manually."
                else 
                    $("#place_address").val(results[0].formatted_address)

            )
        )

placesController.prototype.new = () ->
    places = this.params['place']

    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]

        position = new google.maps.LatLng(-48.19472, 76.61198)

        map = new google.maps.Map(mapContainer,
            center: position
            zoom: 8
        )

        marker = new google.maps.Marker 
            position: position
            map: map 
            draggable: true 

        geocoder = new google.maps.Geocoder()

        marker.addListener('dragend', () ->
            $("#place_latitude").val(this.position.lat())
            $("#place_longitude").val(this.position.lng())
            
            $("#place_address").attr("disabled", "disabled")
            
            geocoder.geocode( { 'latLng' : this.position }, (results, status) ->
                $("#place_address").removeAttr("disabled")

                if results[0] == undefined
                    alert "No address found! Please enter one manually."
                else 
                    $("#place_address").val(results[0].formatted_address)
            )
        )