NavigationExample - Type 3 (NavigationPage) Plugin
===================================================

Adds a new page to the main navigation bar with a brick icon. The
page displays a 2-column tile grid showing live system data for
every major subsystem: battery, solar, AC input, DC loads, tanks,
EV chargers, DC inputs, and system state.

All data comes from Global.* singletons (the same ones used by the
stock Brief, Overview, and Levels pages). Tiles gracefully show
"None" or "No data" for subsystems that aren't present.


1) Build the plugin

The gui-v2-plugin-compiler does not yet support --navigation (type 3),
so a build script is included that runs rcc + base64 directly:

  cd examples/NavigationExample/
  ./build.sh

This produces NavigationExample.json in the current directory.

Alternatively, copy the files to the device and build there
(requires Large image with rcc):

  rsync -avc . root@gx.device.ip.address:/tmp/NavigationExample/
  ssh root@gx.device.ip.address
  cd /tmp/NavigationExample/
  ./build.sh

2) Copy the output file NavigationExample.json to device:

  mkdir -p /data/apps/available/NavigationExample/gui-v2/ && \
  cp NavigationExample.json /data/apps/available/NavigationExample/gui-v2/

3) Enable the plugin:

  ln -sf /data/apps/available/NavigationExample /data/apps/enabled/NavigationExample

4) Restart the GUI:

  svc -t /service/start-gui

5) The navigation bar now shows:

  Brief | Overview | Example | Levels | Notifications | Settings

Tap the brick icon to see the 2x4 tile grid with live data.
