FUNCTION DG_MapsAPI_GetImageAtCenter, center, zoom, WIDTH=width, HEIGHT=height, APIKEY=apikey, MAPID=mapid

errorNo = 0
catch, errorNo
if (errorNo ne 0) then begin
   catch, /CANCEL
   oURL.GetProperty, RESPONSE_CODE=respCode
   print, 'ERROR getting imagery - zoom level too high? Response Code = '+strtrim(respCode,2)
   return, !NULL
endif

if (n_params() ne 2) then begin
   print, 'USAGE: DG_MapsAPI_GetImageAtCenter, center, zoom, WIDTH=width, HEIGHT=height, APIKEY=apikey, MAPID=mapid'
endif


if (n_elements(apiKey) eq 0) then begin
   print, 'ERROR: API key missing'
   return, !NULL
endif
 
 
Recent_Imagery = 'digitalglobe.nal0g75k'
Street_Map =  'digitalglobe.nako6329'
Terrain_Map = 'digitalglobe.nako1fhg'
Transparent_Vectors = 'digitalglobe.nakolk5j'
Recent_Imagery_with_Streets = 'digitalglobe.nal0mpda'

if (n_elements(mapID) eq 0) then begin
  mapID = Recent_Imagery
endif 
  
if (n_elements(width) eq 0) then $
  width = 640
    
if (n_elements(height) eq 0) then $
  height = 640
   


; https://api.mapbox.com/v4/{mapid}/{lon},{lat},{z}/{width}x{height}.{format}?access_token=your-access-token
baseURL = 'https://api.mapbox.com/v4/'

;e = envi(/current)
;v = e.getView()
;center = v.getCenterLocation(/GEO)
;zoom = 12
;width=640
;height=640

format='jpg80'
 
url = baseURL+mapID+'/'+strtrim(center[0],2)+','+strtrim(center[1],2)+','+strtrim(zoom,2)+'/'+strtrim(width,2)+'x'+strtrim(height,2)+'.'+format+'?access_token='+apiKey


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

