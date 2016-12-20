PRO envi_dg_maps_extensions_init

  compile_opt idl2

  e = envi(/current)
  e.addExtension,  'DigitalGlobe Maps Link', 'envi_dg_maps'

END

PRO ENVI_DG_GetMap, cData

  compile_opt idl2

  e = envi(/current)
  v = e.getView()
  l = v.getLayer()
  if (l eq !NULL) then return
  
  center = v.getCenterLocation(/GEO)

  
  mapID = cData.mapIDs[cData.curMapID]
  widget_control, cData.apiKeyText, GET_VALUe = apiKey
  if (apiKey[0] eq '') then begin
    if (not cData.beenWarned) then begin
      a=dialog_message('Please Provide DG Maps API KEY', /INFO)
      widget_control, cData.topBase, MAP=1
      cData.beenWarned = !TRUE
    endif
    return
  endif
  
  img = dg_mapsapi_getImageAtCenter(center, cData.zoom, $
     WIDTH=cData.width, $
     HEIGHT=cData.height, $
     APIKEY=strtrim(apiKey[0],2), $
     MAPID=mapID, /OVERLAY)
     
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
  
  ; attribution
  case mapID of
  'digitalglobe.nal0g75k': begin
    attr="Copyright DigitalGlobe - Terms of Use (http://bit.ly/mapsapiview)"
    attrcolor = 'ffffff'xl
    end 
  'digitalglobe.nako6329': begin
    attr="Copyright Mapbox and OpenStreetMap"
    attrcolor='000000'xl
    end
  'digitalglobe.nako1fhg': begin
    attr="Copyright Mapbox and OpenStreetMap"
    attrcolor='000000'xl
    end
  'digitalglobe.nakolk5j': begin
    attr="Copyright Mapbox and OpenStreetMap"
    attrcolor='ffffff'xl
    end
  'digitalglobe.nal0mpda': begin
    attr="Copyright DigitalGlobe - Terms of Use (http://bit.ly/mapsapiview)"
    attrcolor = 'ffffff'xl
    end 
   else: begin
    attr=' '
    attrcolor='ffffff'xl
    end  
  endcase
  
  device, decompose = 0
  xyouts, 0.5, 0.01, attr, /NORMAL, COLOR=attrcolor, ALIGN=0.5
  
  mapIDText = cData.mapIDHash.where(mapID)
  newtitle = 'DigitalGlobe Map: ('+strtrim(center[0], 2)+','+strtrim(center[1],2)+') ZOOM: '+strtrim(cData.zoom,2)+' ('+mapIDText[0]+')'
  widget_control, cData.tlb, TLB_SET_TITLE = newtitle
  
END

PRO ENVI_DG_Maps_Draw, event

compile_opt idl2

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

compile_opt idl2

widget_control, event.top, GET_UVALUE = cData

e = envi(/current)

; get the current view
v = e.getView()

; this should not happen but you never know
if (v ne !NULL) then begin

  ; make sure there is a layer loaded
  l = v.getLayer()
  if (l ne !NULL) then begin

    cPt = v.getCenterLocation(/GEO)
    if (not array_equal(cPt, cData.curCenter)) then begin
      cData.curCenter = cPt
      ENVI_DG_GetMap, cData
    
    endif
   endif
endif

widget_control, cData.timer, TIMER=1.0

END

PRO ENVI_DG_Maps_Type, event

  compile_opt idl2
  
  widget_control, event.top, GET_UVALUE = cData
  cData.curMapID = event.index
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Zoomin, event

  compile_opt idl2
  
  widget_control, event.top, GET_UVALUE = cData
  cData.zoom++
  cData.zoom=cData.zoom le 0 ? 1 : cData.zoom
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Zoomout, event

  compile_opt idl2
  
  widget_control, event.top, GET_UVALUE = cData
  cData.zoom--
  cData.zoom=cData.zoom le 0 ? 1 : cData.zoom
  ENVI_DG_GetMap, cData
END

PRO ENVI_DG_Maps_Close, event
  
  compile_opt idl2
  
  widget_control, event.top, /DESTROY
  
END

PRO ENVI_DG_Maps_Resize, event

  compile_opt idl2


  widget_control, event.top, GET_UVALUE = cData
  
  ; do not allow the window to size greater than the max width and height
  ; defined by the API
  resizeAgain = !FALSE
  newx = event.x
  newy = event.y
  
  if (event.x gt cData.maxWidth) then begin
    newx = cData.maxWidth
    resizeAgain = !TRUE
  endif
  
  if (event.y gt cData.maxHeight) then begin
    newy = cData.maxHeight
    resizeAgain = !TRUE
  endif
  
  if (resizeAgain) then widget_control, event.top, XSIZE=newx, YSIZE=newy
  
  g = widget_info(event.top, /GEOMETRY)
   
  cData.width = long((event.x - (2*g.xpad)) < cData.maxWidth)
  cData.height = long((event.y - (2*g.ypad)) < cdata.maxHeight)
   
  widget_control, cData.draw, DRAW_XSIZE=cData.width, DRAW_YSIZE=cData.height  
  ENVI_DG_GetMap, cData
  
END



PRO ENVI_DG_Maps

  compile_opt idl2
  
  mapIDNames = [ $
    "Recent_Imagery",$
    "Street_Map" ,$
    "Terrain_Map",$
    "Transparent_Vectors",$
    "Recent_Imagery_with_Streets" $    
    ]

e = envi(/current)
    
tlb = widget_base(TITLE = 'DG Maps', /COLUMN, /TLB_SIZE_EVENTS, GROUP_LEADER=e.widget_id)
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
    
cData = DICTIONARY("zoom", 16, $
  "curCenter", fltarr(2), $
  "maxWidth", 1280, $
  "maxHeight", 1280, $
  "width", 800, $
  "height", 800, $
  "draw", draw, $
  "topbase", topbase, $
  "wid", wid, $
  "tlb", tlb, $
  "apiKeytext", apiKeyText, $
  "timer", mainbase, $
  "curMapId", mapIDHash["Recent_Imagery"], $  
  "mapIDs", mapIDs, $
  "mapIDHash", mapIDHash, $
  "beenWarned", !FALSE, $  
  "curMapID", 0)
  
widget_control, tlb, SET_UVALUE = cData

ENVI_DG_GetMap, cData
widget_control, mainbase, TIMER=1.0

XManager, 'ENVI_DG_Maps', tlb, /NO_BLOCK, EVENT_HANDLER='ENVI_DG_Maps_Resize'

END