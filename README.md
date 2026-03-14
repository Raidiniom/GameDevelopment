# GameDevelopment
Repository for Game Development Activities

Using the Godot Engine. 

# Note
activity#2 file will be used as continuation for all activities in the future   

# Initial Activity
### Hello World
Display simple "Hello World" text in a 2D or 3D scene
![Hello World in a 2D Scene](<screenshots/activity_1/Screenshot 2026-01-31 143240.png>)

## Week 1: Activity #1
Gameplay Mechanics - Player Movement, Physics Bodies, and Collision Detection
![Simple 3D Platformer](<screenshots/Screenshot 2026-02-20 151213.png>)

Gameplay Mechanics
Subtopics: Handling input (keyboard/gamepad), physics bodies (rigid/kinematic), collision detection. Basics of player controllers (movement, jumping).

## Week 2: Activity #2
Endless Runner (Temple Runlike)
![Simple Temple Run](<screenshots/Screenshot 2026-02-23 220847.png>)

Tilemaps for grid-based levels, adding hazards (spikes/traps), designing flow (pacing, difficulty curves). 
Activity : Design of 2 levels for an endless runner (2D or 3D); Level 1 should be noticeable easier than level 2. Implement traps. No HP, once caught in trap restart from the beginning of the level. There should be a notification when entering level 2.

## Week 3: 
### Activity1 UI/UX & Audio
Subtopics:
      HUD elements (health bars, scores), menu systems (CanvasLayer), audio
      buses for mixing SFX/music.
Exercises:
      Integrate UI into your game proto; add sound effects, walk, run, slash, etc. You may also add game music, introduction, and so on.

### Activity 2 AI & Enemies
Subtopics:
      Pathfinding navigation, finite state machines for behaviors
      (patrol/attack), enemy AI patterns.
Exercises:
      Add enemies to your game (note enemies, not obstacles)

![Sample Code and Nodes](<screenshots/Screenshot 2026-02-27 144815.png>)

## Week 4 
### Activity 1 :3D Basics & Optimization
Subtopics:
      3D nodes (meshes, cameras), lighting (DirectionalLight), profiling tools
      for FPS optimization.
Exercises:
      Convert your 2D proto to 3D; optimize for 60 FPS.

### Activity 2 : Export Game to Mobile APK

![Android APK](<screenshots/evidence.jpg>)
![Screenshot](<screenshots/mobile_game.jpg>)
<video src="screenshots/video_mobile_game.mp4" controls></video>

## Week 5
### Activity 1 Multiplayer (basic cloud server) 
Nakama client setup, authentication, matchmaking & relayed realtime sync. 
Add basic 2-player movement sync to an existing prototype (e.g., top-down shooter or platformer); commit with working join/match demo.    Multiplayer (basic cloud server)
Subtopics: 
      Installing Nakama Godot SDK, connecting to Heroic Cloud or local Nakama server (Docker quick-start), device/email authentication, creating/joining matches via matchmaking or code, using Nakama's relayed multiplayer (socket + match messages), syncing player position/inputs with MultiplayerSynchronizer or manual RPC-like messages via Nakama.

![UI Login](<screenshots/ui_multiplayer.png>)

![Multiplayer In Game](<screenshots/in_game.png>)
![Multiplayer In Game](<screenshots/in_game_v2.png>)