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

local LrPrefs = import "LrPrefs"

require "FocusPointPrefs"

-- To avoid nil pointer errors in case of "dirty" update installation (copy new over old files)
FocusPointPrefs.InitializePrefs(LrPrefs.prefsForPlugin(nil))

-- Getting the latest released version number requires an async HTTP call
-- that must not be performed in INFO section so it's done here
FocusPointPrefs.getLatestVersion()
