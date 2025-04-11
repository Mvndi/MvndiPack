###
# Generates all files for ship skins. Run with arguments: ship (cog, galley, etc.), part (hull, stern, etc.) and the name of the skin texture (test, red_stripes, etc.)
###

import os
import sys
import shutil
import json


# Get input
ship = sys.argv[1]
part = sys.argv[2]
skin = sys.argv[3]

partIndex = ["bow","hull","mast","stern"].index(part)


# Get dirs
scriptDir = os.path.dirname(__file__)
modelDir = os.path.join(scriptDir, f"models/vehicles/ships/{ship}/{part}")
targetModelDir = os.path.join(modelDir, skin)
itemPath = os.path.join(scriptDir, f"items/ships/{ship}.json")


# Copy from test skin
shutil.copytree(os.path.join(modelDir, "test"), targetModelDir)

# Replace "test" with skin name in all files
for root, dirs, fileNames in os.walk(targetModelDir):
  for fileName in fileNames:
    fileName = os.path.join(root, fileName)
    with open(fileName, "r") as file:
      contents = file.read()
      with open(fileName, "w") as file:
        file.write(contents.replace("test", skin))


# Add to item definition
with open(itemPath, "r") as file:
  itemData = json.loads(file.read())
  data = itemData["model"]["models"][partIndex]["cases"][0]

  dataString = str(data).replace("test", skin).replace("\'","\"")
  data = json.loads(dataString)
  itemData["model"]["models"][partIndex]["cases"].append(data)

  with open(itemPath, "w") as file:
    file.write(json.dumps(itemData, indent=2))
