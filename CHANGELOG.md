## 2.1c

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

## 2.1b

**Fixed ConVar Initialization order**

## 2.1a

**Deflect**

Duration from `5 -> 10`

**Added double jump option**

`gw_double_jump_enabled` default is `0` (disabled)

**Fixed configs being incorrect after a gamemode update**

## 2.1

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

## 2.0d

Hiders will respawn during prep again. But they will keep the ability they had before death.

## 2.0c

Fixed Timelapse sound not playing.

## 2.0b

Fixed a bug related to weapon HUDs.

## 2.0a

Added Ability that was supposed to be in 2.0

**Timelapse**

Travel `9` seconds back in time.  


## 2.0

### GUI Config Editor

Press F1 to modify the Server config.  

Currently Supports:  

* Hiding & Seeker models
* Abilities
* Team Colors

### Reworked Seeker Movement

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

### Abilities

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
