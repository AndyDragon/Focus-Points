--[[
  Copyright 2016 Whizzbang Inc

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--]]

--[[
  A collection of delegate functions to be passed into the DefaultPointRenderer when
  the camera is Fuji
--]]

local LrStringUtils = import "LrStringUtils"
require "Utils"

FujifilmDelegates = {}

--[[
-- metaData - the metadata as read by exiftool
--]]
function FujifilmDelegates.getAfPoints(photo, metaData)
  local focusPoint = ExifUtils.findFirstMatchingValue(metaData, { "Focus Pixel" })
  if focusPoint == nil then
    return nil
  end
  local values = split(focusPoint, " ")
  local x = LrStringUtils.trimWhitespace(values[1])
  local y = LrStringUtils.trimWhitespace(values[2])
  if x == nil or y == nil then
    return nil
  end

  local imageWidth = ExifUtils.findFirstMatchingValue(metaData, { "Exif Image Width" })
  local imageHeight = ExifUtils.findFirstMatchingValue(metaData, { "Exif Image Height" })
  if imageWidth == nil or imageHeight == nil then
    return nil
  end

  local orgPhotoWidth, orgPhotoHeight = DefaultPointRenderer.getNormalizedDimensions(photo)
  local xScale = orgPhotoWidth / imageWidth
  local yScale = orgPhotoHeight / imageHeight
  
  logInfo("Fujifilm", "AF points detected at [" .. math.floor(x * xScale) .. ", " .. math.floor(y * yScale) .. "]")

  local result = {
    pointTemplates = DefaultDelegates.pointTemplates,
    points = {
      {
        pointType = DefaultDelegates.POINTTYPE_AF_SELECTED_INFOCUS,
        x = x * xScale,
        y = y * yScale,
        width = 300,
        height = 300
      }
    }
  }

  -- Let see if we have detected faces
  local detectedFaces = ExifUtils.findFirstMatchingValue(metaData, { "Faces Detected" })
  if detectedFaces ~= nil and detectedFaces ~= "0" then
    local coordinatesStr = ExifUtils.findFirstMatchingValue(metaData, { "Face Positions" })
    if coordinatesStr ~= nil then
      local coordinatesTable = split(coordinatesStr, " ")
      for i=1, detectedFaces, 1 do
        local x1 = coordinatesTable[4 * (i-1) + 1] * xScale
        local y1 = coordinatesTable[4 * (i-1) + 2] * yScale
        local x2 = coordinatesTable[4 * (i-1) + 3] * xScale
        local y2 = coordinatesTable[4 * (i-1) + 4] * yScale
        logInfo("Fujifilm", "Face detected at [" .. math.floor((x1 + x2) / 2) .. ", " .. math.floor((y1 + y2) / 2) .. "]")
        table.insert(result.points, {
          pointType = DefaultDelegates.POINTTYPE_FACE,
          x = (x1 + x2) / 2,
          y = (y1 + y2) / 2,
          width = math.abs(x1 - x2),
          height = math.abs(y1 - y2)
        })
      end
    end
  end

--[[
  Modified by Andy Lawrence AKA Greybeard to add visual representation of Fujifilm subject tracking
  Requires Exiftool minimum version 12.44
  (23rd August 2022)
--]]
  -- Subject detection
    local coordinatesStr = ExifUtils.findFirstMatchingValue(metaData, { "Face Element Positions" })
    if coordinatesStr ~= nil then
      local coordinatesTable = split(coordinatesStr, " ")
      if coordinatesTable ~= nil then
        local objectCount = #(coordinatesTable) / 4
        for i=1, objectCount, 1 do
          local x1 = coordinatesTable[4 * (i-1) + 1] * xScale
          local y1 = coordinatesTable[4 * (i-1) + 2] * yScale
          local x2 = coordinatesTable[4 * (i-1) + 3] * xScale
          local y2 = coordinatesTable[4 * (i-1) + 4] * yScale
          logInfo("Fujifilm", "Face detected at [" .. math.floor((x1 + x2) / 2) .. ", " .. math.floor((y1 + y2) / 2) .. "]")
          table.insert(result.points, {
            pointType = DefaultDelegates.POINTTYPE_FACE,
            x = (x1 + x2) / 2,
            y = (y1 + y2) / 2,
            width = math.abs(x1 - x2),
            height = math.abs(y1 - y2)
          })
        end
      end
    end

--[[
  Modified by Andy Lawrence AKA Greybeard to add visual representation of Fujifilm tele-converter crop area
  Requires Exiftool minimum version 12.82
  (8th April 2024)
--]]
  -- Digital Tele-converter crop area
    local cropsizeStr = ExifUtils.findFirstMatchingValue(metaData, { "Crop Size" })
    local croptopleftStr = ExifUtils.findFirstMatchingValue(metaData, { "Crop Top Left" })
    if cropsizeStr ~= nil then
      local cropsizeTable = split(cropsizeStr, " ")
      if cropsizeTable ~= nil then
        if croptopleftStr ~= nil then
          local croptopleftTable = split(croptopleftStr, " ")
          if croptopleftTable ~= nil then
            local x1 = croptopleftTable[1] * xScale
            local y1 = croptopleftTable[2] * yScale
            local x2 = (cropsizeTable[1]+croptopleftTable[1]) * xScale
            local y2 = (cropsizeTable[2]+croptopleftTable[2]) * yScale
            logInfo("Fujifilm", "Crop area at [" .. math.floor((x1 + x2) / 2) .. ", " .. math.floor((y1 + y2) / 2) .. "]")
            table.insert(result.points, {
              pointType = DefaultDelegates.POINTTYPE_CROP,
              x = (x1 + x2) / 2,
              y = (y1 + y2) / 2,
              width = math.abs(x1 - x2),
              height = math.abs(y1 - y2)
            })
          end
        end
      end
    end

  return result
end
