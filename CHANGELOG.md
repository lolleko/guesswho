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

The crowbar `3` Dash charges.
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
