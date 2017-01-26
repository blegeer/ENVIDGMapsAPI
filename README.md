# ENVIDGMapsAPI
ENVI extension to display DG Maps

## Introduction
This ENVI plugin creates a windows that displays DigitalGlobe imagery located within the ENVI display extent. A subscription to the DigitalGlobe MapsAPI (http://developer.digitalglobe.com) is required for use. This plugin has only been tested on ENVI 5.3. 

## Installation
1. Download the envi_dg.maps.sav
2. Copy the envi_dg_maps.sav file to the ENVI extensions directory on your platform
  1. Windows: c:\users\\\<login>\\.idl\envi\extensions5_3 directory
  2. Linux: /users/\<login>/.idl/envi/extensions5_3 on Linux/Mac
3. Restart ENVI

The extension should appear in the "Extensions" folder in the ENVI toolbox. Titled "DigitalGlobe Maps Link"

## Usage
1. Double click on the extension to start. 
![Plugin Start](https://github.com/blegeer/ENVIDGMapsAPI/blob/master/Screenshots/BlankStartup.png "Blank Startup")
2. Move the mouse to the upper left of the extension window until the panel appears
![Plugin Start](https://github.com/blegeer/ENVIDGMapsAPI/blob/master/Screenshots/BlankStartup_w_menu.png "Blank Startup")
3. In the panel - enter your DG Maps API Key. 
![Plugin Start](https://github.com/blegeer/ENVIDGMapsAPI/blob/master/Screenshots/BlankStartup_w_menu_apikey.png "Blank Startup")
4. Load your imagery or vectors into the ENVI display - the plugin will update with the DG imagery that corresponds to the extent of the envi display.
![Plugin Start](https://github.com/blegeer/ENVIDGMapsAPI/blob/master/Screenshots/ENVIwithPlugin.png "Blank Startup")
5. Use the mouse wheel or buttons on the panel to zoom in and out of the imagery within the plugin. 
6. When there are multiple views in the ENVI display, the plugin will show the extent of the currently selected view. 

Use the menu in the upper left corner to switch map ids between imagery, street maps, terrain, etc. 
![Plugin Start](https://github.com/blegeer/ENVIDGMapsAPI/blob/master/Screenshots/Imagery_Menu_Drop.png "Blank Startup")







