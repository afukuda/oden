String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

setup = ->
  preferences.rulerUnits = Units.PIXELS

main = ->
  original = hiddenLayer app.activeDocument

  for layerSet in app.activeDocument.layerSets
    continue unless layerSet.name.startsWith '#'
    layerSet.visible = true
    run layerSet
    layerSet.visible = false

  restoreLayer app.activeDocument, original

run = (layerSet) ->
  original_active = hiddenSystemLayer layerSet

  fileName = layerSet.name[1..]
  maxLayer = layerSet.artLayers.getByName "#Max"
  minLayer = layerSet.artLayers.getByName "#Min"
  generate_image(fileName, minLayer, maxLayer)

  restoreSystemLayer layerSet, original_active

generate_image = (fileName, minLayer, maxLayer) ->
  x1 = maxLayer.bounds[0]
  y1 = maxLayer.bounds[1]
  x2 = maxLayer.bounds[2]
  y2 = maxLayer.bounds[3]
  w  = x2 - x1
  h  = y2 - y1
  t1_w = activeDocument.width
  t1_h = activeDocument.height
  activeDocument.resizeCanvas x2, y2, AnchorPosition.TOPLEFT
  t2_w = activeDocument.width
  t2_h = activeDocument.height
  activeDocument.resizeCanvas w, h, AnchorPosition.BOTTOMRIGHT
  save(fileName)
  activeDocument.resizeCanvas t2_w, t2_h, AnchorPosition.BOTTOMRIGHT
  activeDocument.resizeCanvas t1_w, t1_h, AnchorPosition.TOPLEFT

save = (fileName) ->
  pngOptions = new PNGSaveOptions()
  filepath = activeDocument.path + "/" + fileName + ".png"
  app.activeDocument.saveAs(File( filepath ), pngOptions, true, Extension.LOWERCASE)

hiddenLayer = (root) ->
  original = {}
  for layer in root.layers
    original[layer.name] = layer.visible
    layer.visible = false
  original

hiddenSystemLayer = (root) ->
  original = {}
  for layer in root.layers
    continue unless layer.name[0] == '#'
    original[layer.name] = layer.visible
    layer.visible = false
  original

restoreLayer = (root, original) ->
  alert('restoreLayer')
  for layer in root.layers
    alert(layer.name)
    alert(original[layer.name])
    layer.visible = original[layer.name]

restoreSystemLayer = (root, original) ->
  for layer in root.layers
    continue unless layer.name[0] == '#'
    layer.visible = original[layer.name]

setup()
main()
