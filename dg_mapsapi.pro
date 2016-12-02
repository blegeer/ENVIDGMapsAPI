PRO DG_MapsAPI

apiKey = 'pk.eyJ1IjoiZGlnaXRhbGdsb2JlIiwiYSI6ImNpdmp3cnRlajAxeXEyb2xibTJxcGpjdm4ifQ.Rbs0vFo2B83veUKX44P7cg'

Recent_Imagery = 'digitalglobe.nal0g75k'
Street_Map =  'digitalglobe.nako6329'
Terrain_Map = 'digitalglobe.nako1fhg'
Transparent_Vectors = 'digitalglobe.nakolk5j'
Recent_Imagery_with_Streets = 'digitalglobe.nal0mpda'

; https://api.mapbox.com/v4/{mapid}/{lon},{lat},{z}/{width}x{height}.{format}?access_token=your-access-token
baseURL = 'https://api.mapbox.com/v4/'

e = envi(/current)
v = e.getView()
center = v.getCenterLocation(/GEO)
zoom = 12
width=640
height=640
format='png'

 
url = baseURL+Recent_Imagery+'/'+strtrim(center[0],2)+','+strtrim(center[1],2)+','+strtrim(zoom,2)+'/'+strtrim(width,2)+'x'+strtrim(height,2)+'.'+format+'?access_token='+apiKey
print, url

oURL = IDLNetURL( $
  SSL_VERIFY_HOST=0, $
  SSL_VERIFY_PEER=0)
rawImg = oURL->Get(URL=url, /BUFFER)
help, rawImg

fTmp=filepath('tmp'+strtrim(long64(systime(1)),2)+'.dat', /TMP)
openw, lun, fTmp, /GET_LUN
writeu, lun, rawImg
free_lun, lun
img = read_image(fTmp)
file_delete, fTmp

i = image(img)


END

