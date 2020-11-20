#!/usr/bin/with-contenv sh
USER_HOME=/home/${USER_NAME}
if [ ! -d $USER_HOME/.config/autostart ] ; then
   mkdir $USER_HOME/.config/autostart
fi
cp /config/Desktop/firefox-startup.desktop $USER_HOME/.config/autostart
chown -R $USER_NAME:$USER_NAME $USER_HOME/.config

cat << EOF_FF > /usr/lib/firefox/firefox.cfg
// IMPORTANT: Start your code on the 2nd line
pref("app.update.auto", false);
pref("app.update.enabled", false);
pref("browser.tabs.remote.autostart", false);
pref("app.update.lastUpdateTime.addon-background-update-timer", 1182011519);
pref("app.update.lastUpdateTime.background-update-timer", 1182011519);
pref("app.update.lastUpdateTime.blocklist-background-update-timer", 1182010203);
pref("app.update.lastUpdateTime.microsummary-generator-update-timer", 1222586145);
pref("app.update.lastUpdateTime.search-engine-update-timer", 1182010203);
pref("browser.startup.homepage", "localhost:3000");
pref("app.normandy.first_run", false);
pref("startup.homepage_welcome_url", "");
pref("datareporting.policy.firstRunURL", "");
EOF_FF

# set the home page
cat << EOF_CFG > /usr/lib/firefox/defaults/pref/autoconfig.js
pref("general.config.filename", "firefox.cfg");
pref("general.config.obscure_value", 0);
pref("browser.shell.checkDefaultBrowser", 0);
EOF_CFG
