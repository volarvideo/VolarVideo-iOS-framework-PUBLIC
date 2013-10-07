VolarVideo-iOS-framework-PUBLIC
===============================

VolarVideo iOS framework to query CMS and present content

## Required frameworks to build the demonstration apps:
- CoreLocation.framework/
- Security.framework/
- CFNetwork.framework/
- libicucore.lib/
- VVMoviePlayer.embeddedframework/VVMoviePlayer.framework/
- MapKit.framework/
- libxml2.dylib
- EventKitUI.framework/
- EventKit.framework/
- CoreMedia.framework/
- AVFoundation.framework/
- libz.dylib
- SystemConfiguration.framework/
- MediaPlayer.framework/
- ImageIO.framework/
- MessageUI.framework/
- QuartzCore.framework/
- UIKit.framework/
- Foundation.framework/
- CoreGraphics.framework/
- SenTestingKit.framework/
- TestFlight/libTestFlight.a
- libPusher.a
    - if using Cocoa pods, add the following line to PodFile: pod 'libPusher', '1.4'
    - else if statically added:https://github.com/lukeredpath/libPusher/wiki/Adding-libPusher-to-your-project

## To include the VVMoviePlayer.framework:
Download the contents of the VVMoviePlayer.embeddedframework directory.  From finder, drag the VVMoviePlayer.embeddedframework directory into your XCode project navigator.  Be sure to:

- Check "Copy items into destination group's folder (if needed)" 
- Select "Create groups for any added folders"
- Check all your target applications

NOTE: Reachability is embedded in VVMoviePlayer.framework.   If you want to use Reachability in your project, just include Reachbility.h (not Reachbility.m).

You may wish to set "View controller-based status bar appearance" to NO in your apps info.plist,.  This will prevent the status bar from appearing over the VVMoviePlayer in some screen orientations.