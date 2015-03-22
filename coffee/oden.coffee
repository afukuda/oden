String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

originalFilePath = ''
originalFileName = ''

setup = ->
  originalFilePath = app.activeDocument.path
  originalFileName = app.activeDocument.name
  preferences.rulerUnits = Units.PIXELS

main = ->
  copiedImage = app.activeDocument.duplicate(activeDocument.name[..-5] + '.oden.pdf')
  original = hiddenLayer copiedImage

  for layerSet in copiedImage.layerSets
    continue unless layerSet.name.startsWith '#'
    layerSet.visible = true
    run layerSet
    layerSet.visible = false

  restoreLayer copiedImage, original
  copiedImage.close(SaveOptions.DONOTSAVECHANGES)

run = (layerSet) ->
  original_active = hiddenSystemLayer layerSet

  fileName = layerSet.name[1..]
  maxLayer = layerSet.artLayers.getByName "#Max"
  minLayer = layerSet.artLayers.getByName "#Min"
  clipping_image(fileName, minLayer.bounds, maxLayer.bounds)

  restoreSystemLayer layerSet, original_active

clipping_image = (fileName, minLayerBounds, maxLayerBounds) ->
  x1 = maxLayerBounds[0]
  y1 = maxLayerBounds[1]
  x2 = maxLayerBounds[2]
  y2 = maxLayerBounds[3]
  w  = x2 - x1
  h  = y2 - y1
  t1_w = activeDocument.width
  t1_h = activeDocument.height
  activeDocument.resizeCanvas x2, y2, AnchorPosition.TOPLEFT
  t2_w = activeDocument.width
  t2_h = activeDocument.height
  activeDocument.resizeCanvas w, h, AnchorPosition.BOTTOMRIGHT

  filePath = save_image(fileName, app.activeDocument)
  generate_slice(filePath, fileName, minLayerBounds, maxLayerBounds)

  activeDocument.resizeCanvas t2_w, t2_h, AnchorPosition.BOTTOMRIGHT
  activeDocument.resizeCanvas t1_w, t1_h, AnchorPosition.TOPLEFT

generate_slice = (filePath, fileName, min, max) ->
  a = open(File(filePath))

  x1 = min[0] - max[0]
  y1 = min[1] - max[1]
  x2 = min[2] - max[0]
  y2 = min[3] - max[1]
  w = max[2] - max[0]
  h = max[3] - max[1]

  dx = x1 - x2
  dy = y1 - y2
  originalLayer = a.activeLayer

  createLayerParts(a, originalLayer, 0, 0, x1+2, y1+2, 0, 0) # LeftTop
  createLayerParts(a, originalLayer, 0, y2, x1, h, 0, dy-2) # LeftBottom
  createLayerParts(a, originalLayer, x2, y2, w, h, dx-2, dy-2) # RightBottom
  createLayerParts(a, originalLayer, x2, 0, w, y1, dx-2, 0) # RightTop
  originalLayer.clear()

  a.resizeCanvas ((x1 - 0) + (w - x2)+2), ((y1 - 0) + (h - y2)+2), AnchorPosition.TOPLEFT

  pngOptions = new PNGSaveOptions()
  a.saveAs(File(filePath), pngOptions, true)
  a.close(SaveOptions.DONOTSAVECHANGES)

  # L,R,T,B
  save_text(fileName, x1 + ',' + (w-x2) + ',' + y1 + ',' + (h-y2))

createLayerParts = (doc, originalLayer, x1, y1, x2, y2, dx, dy) ->
  newLayer = originalLayer.duplicate()
  doc.activeLayer = newLayer

  sel = Array(Array(x1, y1),
     Array(x2, y1),
     Array(x2, y2),
     Array(x1, y2),
     Array(x1, y1))
  doc.selection.select(sel)
  doc.selection.invert()
  doc.selection.clear()
  doc.selection.deselect()

  newLayer.translate(dx, dy)

save_text = (fileName, text) ->
  outputFolderPath = originalFilePath + "/" + originalFileName[..-5]
  filepath = outputFolderPath + "/" + fileName + ".oden"

  txtFile = new File(filepath)
  txtFile.open("w", "TEXT")
  txtFile.write(text)
  txtFile.close()

  filepath

save_image = (fileName, document) ->
  outputFolderPath = originalFilePath + "/" + originalFileName[..-5]
  filepath = outputFolderPath + "/" + fileName + ".png"

  outputFolder = new Folder(outputFolderPath)
  outputFolder.remove() if outputFolder.exists
  outputFolder.create()

  pngOptions = new PNGSaveOptions()
  document.saveAs(File( filepath ), pngOptions, true)

  filepath

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
  for layer in root.layers
    layer.visible = original[layer.name]

restoreSystemLayer = (root, original) ->
  for layer in root.layers
    continue unless layer.name[0] == '#'
    layer.visible = original[layer.name]

setup()
main()
alert('complete!')
