/*
   00-start-here-avisblue.js — set kickoff icon to "start-here" so KDE picks
   up the Avisblue logo from /usr/share/icons/hicolor/scalable/apps/start-here.svg.

   Copied from Fedora's plasma-lookandfeel-fedora package
   (org.fedoraproject.fedora.desktop/contents/plasmoidsetupscripts/
   org.kde.plasma.kickoff.js), GPL-2.0-or-later.

   Without this script, kickoff defaults to icon name "start-here-kde", which
   Breeze provides as the Plasma "K" logo. With our hicolor start-here.svg
   in place, switching the icon name lets the launcher render the brand mark.

   Original copyright:
   Copyright (C) 2010 Kevin Kofler <kevin.kofler@chello.at>
   Copyright (C) 2010 Rex Dieter <rdieter@fedoraproject.org>
*/

if (applet.readConfig("icon", "start-here-kde") == "start-here-kde") {
    applet.currentConfigGroup = ["General"];
    applet.writeConfig("icon", "start-here");
}
