# 2.2

This is going to be a long one so here is a summary:

## Summary

This is the final update of guess who, meaning there will be no more updates after this one (except bugfixes and translations).
As a result the goal of this update is to deliver long overdue bugfixes and improvements.
The update contains the following highlights:
- Smarter and more performant NPCs
- Reworked all abilities
- New options for server owners
- Improved UI and icons

## NPCs

The NPCs have been completly rewritten.

- Better performance (you can now have more NPCs active on the map if you like)
- Improved jumping & doging logic: This improves support for tight maps and maps with a lot of verticality
- Improved unstuck logic: NPCs will now be able to unstuck themself if stuck in a player or another NPC

## Server Owners

- Server owner can now adjust the news and discord link label via the F1 menu

## Abilities

The objective is quality over qunatity, thats why 3 abilities have benn removed and only one has been added. All other abilities have been reworked to reduce bugs and improve balancing, every ability should now be useful (if used correctly you should be able to escape with them).

- Ability casts now fail properly and report the failure reason in chat, for example: if no target is in range the ability will not be cast and the ability charge will not be consumed
- Added descriptions for all abilities, the descriptions will show at the beginning of the round
- New icons for all abilities
- Improved target halos (outlines around seekers in range)

### Dance Party

**[Removed]**

### Decoy 2.0

**[Removed]**

### Touch the ant

**[Removed]**

### Tumble

**[Added]** Tumble, this ability will launch and ragdoll all seekers in the vicinity into the air.

### Mind Control

- Fixed mind control remnat having an incorrect angle
- Improved target selection, it should be easier to select an NPC to transfer to
- Remnat that is left behind can now be killed
- Maximum transfer range is now 1600

### Teleport

- Added fadout/fadein effect
- Destionation finding has been improved, it is now less likely to get stuck and it should be significantly harder to port outside the map
- Changed range to 2000

### Vampirism

- Reduced life drain now only drains a quarter of the life of seekers in range
- Increased speed boost duration from `3.5` to `4` seconds
- Now only targets seekers within line of sight, that means you can no longer drain life if the seeker is behind a wall

### Timelapse

- Fixed Lua error

### Graviton Surge

- Cleaned up code

### Sudoku

- Fixed a Lua error that prevented the explosiion

### SuperHot

- Reworked visuals (text overlay)
- Now lasts `8` instead of `6` seconds

### Solarflare

- Reduced duration from `7` to `6` seconds
- The blind start is now timed with the visual effect

### Shrink

- Cleaned up code
- Can no longer be cast if no seeker is in range

### Shockwave

- The stun start is now timed with the visual effect
- Can no longer be cast if no seeker is in range

### Ragdoll

- Now shows the correct player color

### Prophunt

- Fixed models being stuck in ground
- Added more possible models
- Updated health and speed calculcation, overall health and speed bnous should be higher

### Deflect

- Increased duration from `10` to `12` seconds

### Decoy

- Improved spawn location detection for decoys
- Now spawns between 2-9 decoys

### Blast off

- Improved visual

## Misc

- Increased seeker dash range

## Maps

As mentioned above the NPCs are now smarter, making a wider range of maps available.
In addition I added some maps to the offical map collection, these maps have improved NPC navifagation.
But feel free to give maps a try that are not in the collection, like I said all maps should work better now!

- [Technically Legal](https://steamcommunity.com/sharedfiles/filedetails/?id=251679939)
- [GTA V Online Apartment](https://steamcommunity.com/sharedfiles/filedetails/?id=884391107)
- [Halo 3 Rats Nest](https://steamcommunity.com/sharedfiles/filedetails/?id=2021417682)
- [SkySraper Construction](https://steamcommunity.com/sharedfiles/filedetails/?id=656886437)
- [Nuketown](https://steamcommunity.com/sharedfiles/filedetails/?id=1812043945)

## Bugfixes

- Guess Who now spams a warning if Enhanced Playermodel Selector is selected

# 2.1h

Added Discord Link to team select screen

# 2.1f / 2.1g

**Disabled Halloween features**

# 2.1e

**Halloween Update**

Added small halloween gimmicks.

**Bug fixes**

# 2.1d

**Solarflare**

Fixed a bug that caused only the local player to be blinded.

**Mind Control** -> **Mind Transfer**

Now only transfers your mind to the npc.

**HUD**

Abilities that have an AOE will now render a halo (glow) around seekers that are in range.

# 2.1c

**Blasting off**

Increased duration seekers are stuck in the air from `1.5->3`

**Vampirism**

Now `doubles` your speed for each hunter hit, this speed boost will last `3.5` seconds.

**Touch the ant**

Increased speed of affected hunters.

Increased damage hunters receive if trampled on.

Fixed ant mode not resetting correctly

**Fixed shrink ability**

**Added new ability icons (created by Jack)**

# 2.1b

**Fixed ConVar Initialization order**

# 2.1a

**Deflect**

Duration from `5 -> 10`

**Added double jump option**

`gw_double_jump_enabled` default is `0` (disabled)

**Fixed configs being incorrect after a gamemode update**

# 2.1

**Disguise**

Duration from `15 -> 25`

**Timelapse**

Duration from `9->15`

**Mind Control**

Added Mind Control allows you to control an NPC for `10` seconds.
Your main body will stay behind, if your main body dies you die.
Once you leave the NPCs mind you will return to your own body.

**Solar Flare**

Blinds seekers in a `400` radius for `7` seconds.

**Touch The Ant**

Shrinks all hunters for `8` seconds.
Their size will be reduced to `10%`.
Their damage will be reduced to `10%`.
Their speed will be reduced to `10%`.
They will also get damage if a hider steps on them.

# 2.0d

Hiders will respawn during prep again. But they will keep the ability they had before death.

# 2.0c

Fixed Timelapse sound not playing.

# 2.0b

Fixed a bug related to weapon HUDs.

# 2.0a

Added Ability that was supposed to be in 2.0

**Timelapse**

Travel `9` seconds back in time.  


# 2.0

## GUI Config Editor

Press F1 to modify the Server config.  

Currently Supports:  

* Hiding & Seeker models
* Abilities
* Team Colors

## Reworked Seeker Movement

**Dash**

Seekers can now dash with the crowbar equipped.
The Dash will launch the seeker in the direction he is looking.

The crowbar has `3` Dash charges.
A new charge is granted every `3` seconds.

increased damage to `40`

**Jump**

The jump power was  increased `200 -> 250`

**Movespeed**

Seekers now walk and sprint at the same speed that the hiders walk/sprint.

## Abilities

**General**

* Added Range Indicator for some abilities
* You can no longer suicide to reroll your ability
* But you can reroll your ability once at the beginning (by pressing Reload)
* Crosshair now only renders on certain abilities

**Deflect**

Now only activates a visual effect if the player is damaged.  
Increased duration `3 -> 5`

**Disguise**

*Secret* :)

**Blasting Off**

Players launched against a ceiling will now be stuck on the ceiling for a short duration `(1.5 seconds)`  
Range is global (affects every seeker).

**Vampirism**

Increased range `300 -> 350`

**Shockwave**

Stun duration increased `3.5 -> 4`  

Fixed a clientside Lua error.

**Dance Party**

Stun duration increased `2 -> 2.5`  
Range remains at `800`.

**Decoy**

Slightly increased chance to get more decoys

**Prophunt**

Fixed a bug that caused, the player hull to be inaccurate when transformed into a prop.

**Superhot**

Increased caster speed `NormalSpeed * 4.5 * 0.3 -> NormalSpeed * 5 * 0.3`  
Speed of other players remains at `NormalSpeed * 0.3`

**Shrink**

Increased player speed:  
`Walk speed 150 -> 175`  
`Run speed 300 -> 350`
