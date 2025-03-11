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


local LrDialogs = import 'LrDialogs'
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import "LrStringUtils"
local LrShell = import "LrShell"
local LrTasks = import "LrTasks"
local LrUUID = import "LrUUID"

require "Info"
require "Log"


--[[--------------------------------------------------------------------------------------------------------------------
   Utilities for string handling
----------------------------------------------------------------------------------------------------------------------]]

--[[
-- Breaks a string in 2 parts at the position of the delimiter and returns a key/value table
-- split("A=D E", "=") -> { "A" = "DE" }
-- str - string to be broken into pieces
-- delim - delimiter
--]]
function splitToKeyValue(str, delim)
  if str == nil then return nil end
  local index = string.find(str, delim)
  if index == nil then
    return nil
  end
  local r = {}
  r.key = string.sub(str, 0, index-1)
  r.value = string.sub(str, index+1, #str)
  return r
end

--[[
-- Breaks a delimited string into a table of substrings
-- split("A B C,D E", " ") -> { "A", "B", "C,D", "E" }
-- str - string to be broken into pieces
-- delim - delimiter
--]]
function splitoriginal(str, delim)
  if str == nil then return nil end
  local t = {}
  local i = 1
  for str in string.gmatch(str, "([^" .. delim .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function split(str, delimiters)
  -- Build a pattern that matches any sequence of characters
  -- that are not one of the delimiters.
  -- This is an extension to the original split function that supported a single delimiter
  if not str then return nil end
  local pattern = "([^" .. delimiters .. "]+)"
  local result = {}
  for token in string.gmatch(str, pattern) do
    table.insert(result, token)
  end
  return result
end

--[[
-- Breaks a delimited string into a table of substrings and removes whitespace
-- split("A B C,D E", " ") -> { "A", "B", "C,D", "E" }
-- str - string to be broken into pieces
-- delim - delimiter
--]]
function splitTrim(str, delim)
  if str == nil then return nil end
  local t = {}
  local i = 1
  for str in string.gmatch(str, "([^" .. delim .. "]+)") do
    t[i] = LrStringUtils.trimWhitespace(str)
    i = i + 1
  end
  return t
end

--[[
 Splits a string into 2 parts: key and value.
 @str  the string to split
 @delim the character used for splitting the string
--]]
function stringToKeyValue(str, delim)
  if str == nil then return nil end
  local index = string.find(str, delim)
  if index == nil then
    return nil
  end
  local r = {}
  r.key = string.sub(str, 0, index-1)
  r.value = string.sub(str, index+1, #str)
  return r
end

--[[
 Gets the nth word from a string
 @str  the string to split into words
 @delim the character used for splitting the string
--]]
function get_nth_Word(str, n, delimiter)
    delimiter = delimiter or ";" -- Default to semicolon if not provided
    local pattern = "([^" .. delimiter .. "]+)" -- Dynamic delimiter pattern
    local count = 0
    for word in string.gmatch(str, pattern) do
        count = count + 1
        if count == n then
            return word:match("^%s*(.-)%s*$") -- Trim leading/trailing spaces
        end
    end
    return nil -- Return nil if n is out of range
end

--[[
 Wrap text across multiple rows to fit maximum column length
 @text       the text to wrap across multiple lines
 @max_length maximum line length
--]]
--
function wrapText(text, delim, max_length)
  local result = ""
  local current_line = ""
  for word in text:gmatch("[^" .. delim .. "]+") do
    word = word:gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace
    if #current_line + #word + 1 > max_length then
      result = result .. current_line .. "\n"
      current_line = word
    else
      if current_line == "" then
        current_line = word
      else
        current_line = current_line .. ", " .. word
      end
    end
  end
  if current_line ~= "" then
    result = result .. current_line
  end
  return result
end

--[[
-- Parses a string in the form of "(width)x(height)"" and returns width and height
-- strDimens - string to be parsed
--]]
function parseDimens(strDimens)
  local index = string.find(strDimens, "x")
  if index == nil then return nil end
  local w = string.sub(strDimens, 0, index-1)
  local h = string.sub(strDimens, index+1)
  w = LrStringUtils.trimWhitespace(w)
  h = LrStringUtils.trimWhitespace(h)
  return tonumber(w), tonumber(h)
  end

--[[--------------------------------------------------------------------------------------------------------------------
   Miscellaneous utilities
----------------------------------------------------------------------------------------------------------------------]]

--[[
-- Searches for a value in a table and returns the corresponding key
-- table - table to search inside
-- val - value to search for
--]]
-- #TODO Isn't there something similar used as a local function elsewhere?
function arrayKeyOf(table, val)
  for k,v in pairs(table) do
    if v == val then
      return k
    end
  end
  return nil
end

--[[ #TODO This code seems to be used nowhere!?
-- Transform the coordinates around a center point and scale them
-- x, y - the coordinates to be transformed
-- oX, oY - the coordinates of the center
-- angle - the rotation angle
-- scaleX, scaleY - scaleing factors
function transformCoordinates(x, y, oX, oY, angle, scaleX, scaleY)
  -- Rotation around 0,0
  local rX = x * math.cos(angle) + y * math.sin(angle)
  local rY = -x * math.sin(angle) + y * math.cos(angle)

  -- Rotation of origin corner
  local roX = oX * math.cos(angle) + oY * math.sin(angle)
  local roY = -oX * math.sin(angle) + oY * math.cos(angle)

  -- Translation so the top left corner become the origin
  local tX = rX - roX
  local tY = rY - roY

  -- Let's resize everything to match the view
  tX = tX * scaleX
  tY = tY * scaleY

  return tX, tY
end
--]]


--[[
  @@public string getTempFileName()
  ----
  Create new UUID name for a temporary file
--]]
function getTempFileName()
  local fileName = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), LrUUID.generateUUID() .. ".txt")
  return fileName
end


--[[ #TODO Documentation!
-- Open filename in associated application as per file extension
-- https://community.adobe.com/t5/lightroom-classic/developing-a-publish-plugin-some-api-questions/m-p/11643928#M214559
--]]
function openFileInApp(filename)
  if WIN_ENV then
    LrShell.openFilesInApp({""}, filename)
  else
    LrShell.openFilesInApp({filename}, "open")
  end
end

--[[ #TODO Documentation!
--]]
function getPhotoFileName(photo)
  if not photo then
    photo = FocusPointDialog.currentPhoto
  end
  if photo then
    return photo:getFormattedMetadata( "fileName" )
  end
end


--[[
  @@public int getWinScalingFactor()
  ----
  Retrieves Windows DPI scaling level registry key (HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics, AppliedDPI)
  Returns display scaling level as factor (100/scale_in_percent)
--]]



function getWinScalingFactor()
  local output = getTempFileName()
  local cmd = "reg.exe query \"HKEY_CURRENT_USER\\Control Panel\\Desktop\\WindowMetrics\" -v AppliedDPI >\"" .. output .. "\""
  local result

  -- Query registry value by calling REG.EXE
  local rc = LrTasks.execute(cmd)
  Log.logDebug("Utils", "Retrieving DPI scaling level from Windosws registry using REG.EXE")
  Log.logDebug("Utils", "REG command: " .. cmd .. ", RC=" .. rc)

  -- Read redirected stdout from temp file and find the line that starts with "AppliedDPI"
  local regOutput = LrFileUtils.readFile(output)
  local regOutputStr = "^"
  local dpiValue, scale
  for line in string.gmatch(regOutput, ("[^\r\n]+")) do
    local item = split(line, " ")
    if item and #item >= 3 then
      if item[1] == "AppliedDPI" and item[2] == "REG_DWORD" then
        dpiValue = item[3]
        scale = math.floor(tonumber(dpiValue) * 100/96 + 0.5)
      end
    end
    regOutputStr = regOutputStr .. line .. "^"
  end
  Log.logDebug("Utils", "REG output: " .. regOutputStr)

  -- Set and log the result
  if dpiValue then
    result = 100 / scale
    Log.logDebug("Utils", string.format("DPI scaling level %s = %sdpi ~ %s%%", dpiValue, tonumber(dpiValue), scale))
  else
    result = 100 / 125
    Log.logWarn("Utils", "Unable to retrieve Windows scaling level, using 125% instead")
  end

  -- Clean up: remove the temp file
  if LrFileUtils.exists(output) and not LrFileUtils.delete(output) then
    Log.logWarn("Utils", "Unable to delete REG output file " .. output)
  end

  return result
end


function updateExists()
  local output = getTempFileName()
  local singleQuoteWrap = '\'"\'"\''
  local cmd, result, url
  local Info = require 'Info.lua'

  if WIN_ENV then
    -- windows needs " around the entire command and then " around each path
    cmd = "curl.exe -I " .. FocusPointPrefs.latestReleaseURL .. " > " .. output .. "\""
  else
    cmd = "curl -I " .. FocusPointPrefs.latestReleaseURL .. " > '" .. output .. "'"
  end

  -- Call curl.exe to get 'latest' resolved to 'tags/vX.Y.ZZZ'
  local rc = LrTasks.execute(cmd)
  if (rc == 0) then
    -- Parse curl output to find the resolved URL
    local curlOutput = LrFileUtils.readFile(output)
    for line in string.gmatch(curlOutput, ("[^\r\n]+")) do
      local item = split(line, " ")
      if item and #item >= 2 then
        if item[1] == "Location:" then
          url = LrStringUtils.trimWhitespace(item[2])
          Log.logDebug("ExifUtils", "Update check, URL retrieved for latest release -> " .. url)
          local major, minor, revision = url:match("v(%d+)%.(%d+)%.(%d+)")
          if major and minor and revision then
            -- we have a valid version number from the URL
            local pluginVersion = Info.VERSION
            if tonumber(major) > pluginVersion.major-1 then
              result = true
            elseif tonumber(major) == pluginVersion.major then
              if  tonumber(minor) > pluginVersion.minor then
                result = true
              elseif tonumber(minor) == pluginVersion.minor then
                result = tonumber(revision) > pluginVersion.revision
              end
            end
          else
            Log.logWarn("Utils", "Update check failed, no valid combination of major, minor and revision number")
          end
          break
        end
      end
    end
    if not url then
      Log.logWarn("Utils", "Update check command failed, URL of tagged release not found")
    end
  else
    Log.logWarn("Utils", "Update check command failed (rc=" .. rc ..") : " .. cmd)
  end

  -- Log info message
  if result then
    Log.logInfo("System", "Update available for plugin -> " .. url)
  end

  -- Clean up: remove the temp file
  if LrFileUtils.exists(output) and not LrFileUtils.delete(output) then
    Log.logWarn("Utils", "Unable to delete curl output file " .. output)
  end

  return result
end


--[[
  @@public void errorMessage(string msg)
  ----
  Displays an error message
  Returns
--]]
function errorMessage(msg)
  FocusPointDialog.errorsEncountered = msg
  return LrDialogs.confirm(msg, getPhotoFileName(), "Continue", "Stop")
end
