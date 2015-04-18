SaitoHUD is a very advanced toolkit for Garry's Mod that adds a number of useful tools for debugging Lua code and playing in sandbox. A number of its features are HUD-related, but a number of features are also just general tools. SaitoHUD does **not** add useless things such as a new health meter a new weapon display. **Most of SaitoHUD's features cannot be found in any other addon.**

A small number of features:

  * Highlight selected entities using advanced syntax such as `bbox_filter mdl=8x8` (to highlight entities with "8x8" in their model name) or `bbox_filter (exp and -wire) or mdl=barrel or dist=2000`. You can highlight entities by showing [coordinate triads](Screenshots#Triads_Filter.md), [bounding boxes](Screenshots#Bounding_Box_Filter.md), [velocity vectors](Screenshots#Velocity_Arrows_Filter.md), class names, [model paths](Screenshots#Overlay_Filter.md), and/or materials.
  * Show [very detailed entity and player information](Screenshots#Entity_Information.md) for the object in your crosshair. SaitoHUD will not show you _just_ some useless simplified class name -- it will show you model, material, color, position, angle, and much more.
  * Show the names of all players on the server on your HUD and optionally highlight all your Steam friends so that you can spot them better. This feature **automatically disables** on non-sandbox gamemodes so you can play legitimately on roleplay and other servers.
  * [Trace of the path of movement for an entity](Screenshots#Sampling.md), with customizable data collection intervals and customizable data point history size. Follow exactly where a entity moves to.
  * Improve Stranded with a context-sensitive mouse gesture menu and [colorful resource names](Screenshots#Colored_Resource_Names.md).
  * Use a [customizable mouse gesture menu](Screenshots#Context-Sensitive_Gesture_Menu.md) for Sandbox.
  * Make a [trace of an orthogonal line](Screenshots#Orthogonal_Line_Tracing.md) to a surface.
  * Perform [analysis of reflections](Screenshots#Reflection_Analysis.md), with adjustable number of bounces.
  * Measure distances with the client-side [path measurement tools](Screenshots#Path_Measurement.md), with multiple point and polygon support.
  * Use a very powerful client-side flashlight for illuminating dark rooms.
  * Use the bullt-in sound browser that only lists sounds from the GCF files.
  * Quickly make calculations with SaitoHUD's [built in calculator](Screenshots#Calculator.md) with variable support. You don't press annoying addition or multiplication buttons -- you can enter `3+2*sin(4/2)` directly!
  * Fly around the area by using the free spectate mode, which detaches your camera from your position.
  * Use the usermessage debugger to view a list of the usermessages being sent, as well as their frequency and number. You can identify problems of "lag" by using this feature to find offending addons.

SaitoHUD **automatically disables its features** on non-sandbox gamemodes.

# Installation #

_**Do not install SaitoHUD to a server. It does not work.**_

There are no stable of SaitoHUD at the moment, but you may checkout the current development copy. Use the following checkout URL: `http://saitohud.googlecode.com/svn/trunk/src/SaitoHUD/`