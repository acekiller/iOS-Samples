GKRocket

================================================================================
DESCRIPTION:

The GKRocket sample application demonstrates the major features of GameKit.  It uses GKSession and GKVoiceChatService in a two player networked voice enabled game.

The code demonstrates using GKSession to connect devices without using PeerPicker.  It shows how to use GKSession to set up a GKVoiceChatService between two peers, as well as how to send both voice and game data over the GKSession.  Build the game simply by opening it with Xcode and clicking on Build and Go.

To play the game, use two devices or Simulators with microphones.  Both devices must be on the same network or within Bluetooth range to see each other.  Available peers will appear in the peer list.  Upon selecting a peer, the peer will be asked to accept or reject the invitation.  If the peer accepts, both players will enter the game screen, in which each player controls the thrust of their rocket by yelling into the microphone on the device.

The goal is to bounce a ball into the other player's end of the screen to score points and prevent the ball from going into their own end of the screen.  Players can talk without thrusting their rockets by touching the screen.  Untouching resumes thrusting.

===========================================================================
BUILD REQUIREMENTS:

iPhone OS 3.1

===========================================================================
RUNTIME REQUIREMENTS:

iPhone OS 3.1

===========================================================================
PACKAGING LIST:

GKRocketAppDelegate.h
GKRocketAppDelegate.m
UIApplication's delegate class, the central controller of the application.

GameLobbyController.h
GameLobbyController.m
Lists available peers and handles the user interface related to connecting to
a peer.

SessionManager.h
SessionManager.m
Manages the GKSession and GKVoiceChatService.  While the game is
running, it transfers game packets to and from the game and the peer.

RocketController.h
RocketController.m
Controls the logic, controls, networking, and view of the actual game.

RocketView.h
RocketView.m
Displays the game's graphics.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:



Copyright (C) 2010 Apple Inc. All rights reserved.
