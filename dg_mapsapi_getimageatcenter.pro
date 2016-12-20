FUNCTION DG_MapsAPI_GetImageAtCenter, center, zoom, WIDTH=width, HEIGHT=height, APIKEY=apikey, MAPID=mapid, OVERLAY=overlay

compile_opt idl2


; check errors - the most common will be 401 (unauthorized) or 403 (no resp)
; 422 will come back if the geoJson is malformed as well
errorNo = 0
catch, errorNo
if (errorNo ne 0) then begin
   catch, /CANCEL
   oURL.GetProperty, RESPONSE_CODE=respCode
   print, 'ERROR getting imagery Response Code = '+strtrim(respCode,2)
   case respCode of
    401: print, 'API key is invalid'
    403: print, 'Zoom level too high'
    422: print, 'Badly formed request'
    else: print, 'ERROR getting imagery Response Code = '+strtrim(respCode,2)
   endcase
   
   return, !NULL
endif

; check the params
if (n_params() ne 2) then begin
   print, 'USAGE: DG_MapsAPI_GetImageAtCenter, center, zoom, WIDTH=width, HEIGHT=height, APIKEY=apikey, MAPID=mapid'
endif

; make sure the apiKey was sent
if (n_elements(apiKey) eq 0) then begin
   print, 'ERROR: API key missing'
   return, !NULL
endif
 
; Maps API map types 
Recent_Imagery = 'digitalglobe.nal0g75k'
Street_Map =  'digitalglobe.nako6329'
Terrain_Map = 'digitalglobe.nako1fhg'
Transparent_Vectors = 'digitalglobe.nakolk5j'
Recent_Imagery_with_Streets = 'digitalglobe.nal0mpda'

; Default to recent imagery
if (n_elements(mapID) eq 0) then begin
  mapID = Recent_Imagery
endif 
  
; default width and height
if (n_elements(width) eq 0) then $
  width = 640
    
if (n_elements(height) eq 0) then $
  height = 640
   

; maps API URL
; https://api.mapbox.com/v4/{mapid}/{lon},{lat},{z}/{width}x{height}.{format}?access_token=your-access-token
baseURL = 'https://api.mapbox.com/v4/'

;e = envi(/current)
;v = e.getView()
;center = v.getCenterLocation(/GEO)
;zoom = 12
;width=640
;height=640

format='jpg80'

if (keyword_set(overlay)) then begin
  
  if (mapID eq Recent_Imagery) or (mapID eq Recent_Imagery_with_Streets) then begin
    strokeColor = '%23ffffff'
  endif else begin
    strokeColor = '%23777777'    
  endelse
  
  e = envi()
  v = e.getView()
  ext = v.getExtent(/GEO)
  minlon = ext[0]
  maxlon = ext[4]
  minlat = ext[1]
  maxlat = ext[5]
  ;{ "type": "Polygon",
  ;"coordinates": [
  ;[ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ]
  ;]
  ;}
  geoCoords = [[minlon,minlat],[maxlon,minlat],[maxlon,maxlat],[minlon,maxlat],[minlon,minlat]]
  geoHash = hash("type", "Feature", "geometry", hash("type","LineString", "coordinates", geoCoords), "properties", hash("stroke",strokeColor))

  geoJson = 'geojson('+json_serialize(geoHash)+')'
  ; geoJson = 'geojson({"type":"Polygon","coordinates":['+json_serialize(geoCoords)+']})"
  
  url = baseURL+mapID+'/'+geoJson+'/'+strtrim(center[0],2)+','+strtrim(center[1],2)+','+strtrim(zoom,2)+'/'+strtrim(width,2)+'x'+strtrim(height,2)+'.'+format+'?access_token='+apiKey
    
endif else begin
 
  url = baseURL+mapID+'/'+strtrim(center[0],2)+','+strtrim(center[1],2)+','+strtrim(zoom,2)+'/'+strtrim(width,2)+'x'+strtrim(height,2)+'.'+format+'?access_token='+apiKey
  
endelse


oURL = IDLNetURL( $
  SSL_VERIFY_HOST=0, $
  SSL_VERIFY_PEER=0)
rawImg = oURL->Get(URL=url, /BUFFER)


fTmp=filepath('tmp'+strtrim(long64(systime(1)),2)+'.dat', /TMP)
openw, lun, fTmp, /GET_LUN
writeu, lun, rawImg
free_lun, lun
img = read_image(fTmp)
file_delete, fTmp

return, img


END

