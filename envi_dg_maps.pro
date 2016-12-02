PRO ENVI_DG_GetMap, cData

  e = envi(/current)
  v = e.getView()
  center = v.getCenterLocation(/GEO)

  
  mapID = cData.mapIDs[cData.curMapID]
  widget_control, cData.apiKeyText, GET_VALUe = apiKey
  if (apiKey[0] eq '') then begin
    print, 'Missing or invalid API KEY'
    return
  endif
  
  img = dg_mapsapi_getImageAtCenter(center, cData.zoom, $
     WIDTH=cData.width, $
     HEIGHT=cData.height, $
     APIKEY=strtrim(apiKey[0],2), $
     MAPID=mapID)
     
  if (img eq !NULL) then return

  
  
  ;tmpRaster = ENVIRaster(img, INTERLEAVE='bip' )
  ;tmpRaster.save
  ;tmpStretchRaster = ENVILinearPercentStretchRaster(tmpRaster, PERCENT=2.0)
  ;img = tmpStretchRaster.getData()
  ;help, img
  
  wset, cData.wid
  if (size(img, /n_dim) eq 3) then begin
    tv, img, TRUE=1
  endif else if (size(img, /n_dim) eq 2) then begin
    tvscl, img
    print, '2D'
  endif
  
  mapIDText = cData.mapIDHash.where(mapID)
  newtitle = 'DigitalGlobe Map: ('+strtrim(center[0], 2)+','+strtrim(center[1],2)+') ZOOM: '+strtrim(cData.zoom,2)+' ('+mapIDText[0]+')'
  widget_control, cData.tlb, TLB_SET_TITLE = newtitle
  
END

PRO ENVI_DG_Maps_Draw, event

if (event.type eq 7) then begin
  widget_control, event.top, GET_UVALUE = cData
  cData.zoom+=event.clicks
  cData.zoom=cData.zoom le 0 ? 1 : cData.zoom
  
  ENVI_DG_GetMap, cData
  
endif else if (event.type eq 0) then begin
  
  if (event.press eq 1 and event.clicks eq 2) then begin
      widget_control, event.top, GET_UVALUE = cData
      cData.curMapID++
      cData.curMapID = cData.curMapID eq n_elements(cData.mapIDs) ? 0 : cData.curMapID
      ENVI_DG_GetMap, cData
      
  endif
  
endif else if (event.type eq 2) then begin  ; Motion - show/hide floating toolbar
  widget_control, event.top, GET_UVALUE = cData
  g=widget_info(cData.topBase, /GEOMETRY)
  widget_control, cData.topBase, MAP=((cdata.height-event.y) lt g.scr_ysize) AND (event.x lt g.scr_xsize)? 1 :0
endif 

END

PRO ENVI_DG_Maps_Update, event
widget_control, event.top, GET_UVALUE = cData
e = envi(/current)
v = e.getView()
if (v eq !NULL) then return

cPt = v.getCenterLocation(/GEO)
if (not array_equal(cPt, cData.curCenter)) then begin
    cData.curCenter = cPt
    ENVI_DG_GetMap, cData
    
endif
widget_control, cData.timer, TIMER=1.0


END

PRO ENVI_DG_Maps_Type, event
  widget_control, event.top, GET_UVALUE = cData
  cData.curMapID = event.index
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Zoomin, event
  widget_control, event.top, GET_UVALUE = cData
  cData.zoom++
  cData.zoom=cData.zoom le 0 ? 1 : cData.zoom
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Zoomout, event
  widget_control, event.top, GET_UVALUE = cData
  cData.zoom--
  cData.zoom=cData.zoom le 0 ? 1 : cData.zoom
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Close, event
  widget_control, event.top, /DESTROY
  
END

PRO ENVI_DG_Maps

  mapIDNames = [ $
    "Recent_Imagery",$
    "Street_Map" ,$
    "Terrain_Map",$
    "Transparent_Vectors",$
    "Recent_Imagery_with_Streets" $    
    ]
    
tlb = widget_base(TITLE = 'DG Maps', /COLUMN)
mainbase = widget_base(tlb, EVENT_PRO='ENVI_DG_Maps_Update')

; toolbar (topbase) floats in the upper left of the main drawing area and shows/hides
; based on mouse location
topbase = widget_base(mainbase, /column, map=0)
row1 = widget_base(topbase, /ROW)
typelabel = widget_label(row1, value = 'MapID: ')
maptypebutton = widget_droplist(row1, value = mapIDNames,  $
  uname='maptypedroplist', event_pro='ENVI_DG_Maps_Type')

zin = filepath('zoom_in.bmp', subdir = ['resource','bitmaps'])
zout = filepath('zoom_out.bmp', subdir = ['resource','bitmaps'])
killbitmap=filepath('delete.bmp',subdir=['resource','bitmaps'])
helpbitmap=filepath('help.bmp',subdir=['resource','bitmaps'])
zoomin = widget_button(row1, value=zin, /bitmap, TOOLTIP = 'Zoom In', event_pro='ENVI_DG_Maps_zoomin', $
  /flat)
zoomout = widget_button(row1, value=zout, /bitmap, TOOLTIP = 'Zoom Out', event_pro='ENVI_DG_Maps_zoomout', $
  /flat)
  
killbutton = widget_button(row1, value=killbitmap, /flat, /bitmap, TOOLTIP = 'Close', event_pro='ENVI_DG_Maps_close')
; helpbutton = widget_button(topbase, value=helpbitmap, /flat, /bitmap, event_pro='envigoogle_settings')

row2 = widget_base(topbase, /ROW)
apiKeyLabel = widget_label(row2, VALUE = 'API KEY: ')
apiKeyText = widget_text(row2, XSIZE=30, YSIZE=1, /EDITABLE)

draw = widget_draw(mainbase, XSIZE=800, YSIZE=800, /BUTTON_EVENTS, /WHEEL_EVENTS, /MOTION_EVENTS, EVENT_PRO='ENVI_DG_Maps_Draw')
widget_control, tlb, /REALIZE
widget_control, draw, GET_VALUE = wid

mapIDHash = ORDEREDHASH( $
  "Recent_Imagery",'digitalglobe.nal0g75k',$
   "Street_Map" ,'digitalglobe.nako6329',$
   "Terrain_Map",'digitalglobe.nako1fhg',$
   "Transparent_Vectors",'digitalglobe.nakolk5j',$
   "Recent_Imagery_with_Streets",'digitalglobe.nal0mpda' $
  )
  
  mapIDs = ['digitalglobe.nal0g75k',$
    'digitalglobe.nako6329',$
    'digitalglobe.nako1fhg',$
    'digitalglobe.nakolk5j',$
    'digitalglobe.nal0mpda' $
    ]
    
cData = DICTIONARY("zoom", 12, $
  "curCenter", fltarr(2), $
  "width", 800, $
  "height", 800, $
  "topbase", topbase, $
  "wid", wid, $
  "tlb", tlb, $
  "apiKeytext", apiKeyText, $
  "timer", mainbase, $
  "curMapId", mapIDHash["Recent_Imagery"], $  
  "mapIDs", mapIDs, $
  "mapIDHash", mapIDHash, $
  "curMapID", 0)
  
widget_control, tlb, SET_UVALUE = cData

ENVI_DG_GetMap, cData
widget_control, mainbase, TIMER=1.0

XManager, 'ENVI_DG_Maps', tlb, /NO_BLOCK 

END