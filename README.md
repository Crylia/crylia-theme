# Crylia Theme

This theme is inspired by simple bar and many other things that I think look good and fit my theme. AwesomeWM lets you configure your desktop as you want, no compromises, the sky is the limit!
This is the reason I choose AwesomeWM.

## FAQ - Wiki

---

If you feel lost, got a problem or just have a question, please check out the wiki first before opening an issue.

## Quick Install

---

### [Installation]()

Installing this theme is rather easy, just copy the repo and put the awesome folder to ~/.config/
But in order for it to work as seen you need some dependencies installed along the way. Here are the main components, but in order for everything to work go [here]().

||Arch|Ubuntu|Why?|
|:-:|:-:|:-:|:-:|
|AwesomeWM|awesome|[Guide here]()|Its your Window Manager lol|
|Rofi|rofi|[Guide here]()|For the application launcher|
|Picom|picom-ibhagwan-git<sup>aur</sup>|[Guide here]()|Compositor, needed for transparency/blur/effects/animations etc|
|||||
## TODO

---

This is my 1.0 release, meaning that I will add many more features as time goes on. At this state the config is usable on (hopefully) all systems complying with my dependency list.

- [ ] Independent Application launcher
- [ ] Alt+Tab like Window switcher
- [ ] Switching trough Keyboard layouts using \<*super*\>+\<*space*\>(like on gnome where you hold down super)
- [ ] System tray needs a lot of work (maybe an own implementation)
- [ ] Manual tiling layout like i3
- [ ] Interactive calendar with online support

## Features

---

Some would say there are more features than a WM needs, I say you can never have enough features (as long as they make some sense).

- [x] Multi screen support
- [x] Interactive taskbar (left, right click and hover over)
- [x] Session option to reboot, shutdown etc
- [x] Multi keyboard layout support + switch widget
- [x] Calendar widget (not interactive)
- [x] Rofi application launcher and window switcher
- [x] Volume / Brightness switcher
- [X] Dock
- [x] Systray

Some stuff planned for the future

- [ ] Calendar OSD
- [ ] GPU/CPU/RAM etc Temparature and Usage widget
- [ ] Extended volume and microphone control
- [ ] More bugs
- [ ] I3 like layout / manual tiling

I've added various widgets you can choose or remove how you like it.

__Including__:<br>
Battery, Network (Wifi, Ethernet), Bluetooth, Volume, Keyboardlayout, Date (with Calendar), Time, Session options, Taglist, Tasklist, Layoutswitcher.

## Known bugs

---

### Please note, the config could easily break since I can only test it on so many systems. Every installation is different

### __If you encounter any bug or question you can't solve, feel free to open a new issue or PR__

- The dock may not work with most flatpaks, snaps, appimages and Icons wont work when a path instead of a program is specified
- The Volume and Backlight keys will be really laggy when changed too fast
- Not every program will use the Icon's pack icon in the taglist and tasklist
- Rounded corners have a transparent corner, this is because of picom
- The dock may or may not hide and show properly, sometimes even jitters
- The Volume OSD wont go over 100% even if the volume is higher(the regular widget works)
- The dock, Volume OSD and Backlight OSD all have very bad implementations and might cause performance issues
- The systay will stay even when empty since there is no way to check how many clients are in the systray
