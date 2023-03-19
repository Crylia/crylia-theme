
# TODO list for my AwesomeWM rice

## Modules

### Applicationlauncher [100% Done]

#### Features

- Automatically collects all .desktop files that are marked as visible and displays them
- Execute application
- Search for an application
- Right click context menu
- Options to execute as sudo, pin to dock or add to desktop
- Infinite scoll (well technically, infinite if you installed infinite apps lol)
- Algorithm to select the best search match
- Keep track of most launched applications and serve them over others

### Audio [0% Done]

#### TODO

- Reliabely fetch audio devices
- Switch inputs
- Fetch programs that make audio
- Mute toggle

### Backlight [100% Done]

#### Features

- Change backlight with your backlight keys
- See the change on a OSD that pops up
- Works with all devices by writing into /usr/class/backlight/`device`

### Bluetooth [95% Done]

#### Features

- Connecting/Disconnecting a device
- Finding other devices and grouping them into paired and not paired
- Removing them from beeing Paired
- Trusting/Untrusting a device
- Toggle Bluetooth on/off
- Scan again for devices
- Update as soon a new device is found
- When removed put it into the discovered list from paired
- Renaming a device
- Pairing a new device
- Dropdown with multiple options per device

#### TODO

- Don't try to create a bluetooth proxy if there is no bluetooth adapter
- Getting and asking for a passcode
- "Greying out" non avaiable options in the dropdown

### Calendar [60% Done]

#### Features

- Read .ical files and put them into the calendar
- Create tasks for every day
- Month/Year switcher
- Saved accross restarts
- Popup with the task informations

#### TODO

- Create a new task for a calendar
- Create an alert that notifies the user
- Week numbers
- Remove a calendar
- Remove a task

### Desktop [40% Done]

#### Features

- Create desktop icons, folders or files
- Drag and drop desktop icons
- Context menu
- Saves accross restart
- Desktop context menu

#### TODO

- Actions for the context menu
- "Open with" in context menu
- Drag across multiple screens
- Proper size calculation for desktop icons and desktop
- Multiscreen support in general
- MIME types for files
- xdg folder types
- Drag-select
- Cross-DE support (e.g. use the same desktop icons as used in KDE or Mate ...)

### crylia_bar [100% Done]

#### Features

- Add widgets into three different bars (Left, Center, Right)
- Hide when no widget is present
- Auto resize based on widgets size
- Automatically loads widgets from config

### crylia_wibox [? Done]

#### Features

- Single bar that can be placed at the bottom
- Automatically loads widgets from config

#### TODO

### Network Controller [50% Done]

#### Features

- List and show all WiFi-AccessPoints
- Connect to an AccessPoint
- Enter a password for each AccessPoint

#### TODO

- Toggle WiFi On/Off
- Mark the connected AccessPoint
- Send signals for connected AccessPoints wifi strength
- Send notifications for various events
- Only show the Module when a WiFi Agent exists

### Notification Center [95% Done]

#### Features

- Multiple widgets (Weather, Profile, Status Bars, Music, Notification, Date Time)
- Keeps track of notification time sent
- Displays bars which visualize various system resources (CPU/GPU-Usage/Temp, Ram, Audio Volume,Mic Volume, Battery, Backlight)
- Fetches the user Profile picture and different informations like name, OS etc
- Shows the current weather with the openweather.com API
- Music widget which can fetch an album cover, song metadata etc
- Do not Disturb button to hide notifications

#### TODO

- Cleanup
- _Maybe_ add more widgets

### Powermenu [100% Done]

#### Feature

- Logout, Reboot, Shutdown, Lock or **Sus**pend system
- Display user profile picture and name or hostname

### Window Switcher[90% Done]

#### Features

- Alt-Tab to cycle trough windows and switch to the tag and focus them

#### TODO

- "Toggle" alt tab to switch between two windows (keep track which was the last one as put it as the first one)
- Rewrite and try to make more performant

## Widgets

## General

- Constantly monitor for a bluetooth adapter to appear and then add the bluetooth module
- Probably the same with WiFi
