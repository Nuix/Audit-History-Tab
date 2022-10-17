Audit History Tab
==============

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) ![This script was last tested in Nuix 9.6](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-9.6-green.svg)

View the GitHub project [here](https://github.com/Nuix/Audit-History-Tab) or download the latest release [here](https://github.com/Nuix/Audit-History-Tab/releases).

# Overview

A tab for workbench that will allow you to access the history records for export and analysis. To simplify the Case history and export behaviour, combining all known requests for scripts into one hopefully simple to use audit history tab.

Help is provided here and upon first run. If there are any issues loading help it can be found under the Audit History Tab.nuixscript\Help.html

# Getting Started

## Setup

Begin by downloading the latest release of this code.
Extract the contents of the archive into your Nuix scripts directory.
In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

Leave the .nuixscript as the extension of the directory.
Then run using the scripts\Exact Wordlist Tab

# Filtering

## Type
The possible values for types are as follows:

"openSession" - occurs at the start of a session with a case (i.e. when the case is opened.)

"closeSession" - occurs at the end of a session with a case (i.e. when the case is closed.)

"loadData" - occurs when data is loaded into the case.

"search" - occurs when a search is performed.

"annotation" - occurs when items are annotated (e.g. tagged.)

"export" - occurs when data or metadata is exported out of the case.

"import" - occurs when data or metadata is imported into the case. The difference from "loadData" is that with "import", the data is directly imported without processing.

"delete" - occurs when data in the case is deleted.

"script" - occurs when a script is executed.

"printPreview" - occurs when a print preview action is executed.


## User
Gets the user who performed the action, this is the the short name of the user as returned by User.getShortName(). If the user does not exist, no records will be returned. On Tab load the users that are available in this case are automaticaly populated.

## After
The start date to filter after (only more recent events will be returned.)

"Today" - Date.today (at 00:00:00)

"Previous Day" - Date.today.prev_day

"Previous Month" - Date.today.prev_month

"Previous Year" - Date.today.prev_year

"*" - Wildcard for all time.

Note:By Default Today is chosen, as potentially a lot of records may be returned.

# Exporting
## Export View
After specifying your Filters and the results view populated you can then click the Export View button. This will prompt if you would like to export details.

No - Export the view as it is, sort order with only the items in the filter. Yes - Export the view and its details, affected item count and the full list of affected guids separated by ;

## Export just a single event log
On the right of the tab is a Go button, the drop down beside this has an option "Export Log Details", This will export the headers for this item and all it's details. Will not export affected items.

## Export affected guids from a single event log
On the right of the tab is a Go button, the drop down beside this has an option "Export GUIDs of affected items", this will export the guids in a text file line deliminated.

## Open Tab with affected items
On the right of the tab is a Go button, the drop down beside this has an option "New Tab with affected items". This will open a tab with all the items affected by the action.

If no items are affected a message will be displayed.

## Tag affected items
On the right of the tab is a Go button, the drop down beside this has an option "Tag affected items".

This will Prompt for a tag name (pipe for subfolders are supported).

Warning:Using this option will result in a new Audit History log entry being made

## Apply Custom Metadata to affected items
On the right of the tab is a Go button, the drop down beside this has an option "Custom Metadata affected items".

This will Prompt for a Custom Metadata name and value to place in that value (type=string)

Warning:Using this option will result in a new Audit History log entry being made


## License

```
Copyright 2019 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
