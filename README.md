# Camera
Cross-platform Camera for Delphi that supports newer APIs

This project aims to implement camera support on devices on multiple platforms, using newer APIs

Usage:

  Documentation is coming. Examine the demo project

  Prior to building the demo (or a project that you include Camera support), you will need to run BuildJar.bat, to build the jar, which will then need to be added to the project in the Libraries node under Android in the Target Platforms list in the Project Manager. You will likely need to modify BuildJar.bat to suit your environment


Reporting issues:

  Please report issues to the Github project from whence this came:

  https://github.com/DelphiWorlds/Camera/issues


Release history:

v0.0.1  2017-03-24

  Initial release

  Includes support for Android only using the Camera2 API, i.e. in Android 5 (Lollipop, API 21) or higher

  Features:

  * Captures the camera and previews on a native control
  * Supports detection of faces, fires the OnDetectedFaces event when faces are detected

  Known issues:

  * No API check as yet, so it'll probably crash on API 20 or lower
  * Preview seems to be larger than the area it is supposed to contain
  * No support for any camera options, such as focus mode, flash etc etc
  * Captured image on face detection is not rotated to the same orientation as the preview
  * Setting the PreviewControl's Visible property to False before the camera is started, then setting it back to True, then starting the camera causes a crash
