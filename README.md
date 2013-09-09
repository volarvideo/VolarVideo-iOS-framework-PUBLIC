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

## To include the VVMoviePlayer.framework:
Download the contents of the VVMoviePlayer.embeddedframework directory.  From finder,
drag the VVMoviePlayer.embeddedframework directory into your XCode project navigator.

NOTE: Reachability is embedded in VVMoviePlayer.framework.   If you want to use Reachability in your project, just include Reachbility.h (not Reachbility.m).
