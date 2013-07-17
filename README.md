# Shiny Wight (working title)
This will be an HTML 5 game for [this](https://www.udacity.com/wiki/CS255/contest) contest

## Getting started

### Dependencies
- [git](http://git-scm.com/)
- [Tiled Map Editor](http://www.mapeditor.org/) (only needed for level design)
- [node](http://nodejs.org/)

### Setup
1. ```git clone https://github.com/despairblue/shiny-wight.git```
2. Run `npm install -g brunch`
3. In the project root dir run `npm install`
4. In the project root dir run `npm up`
5. In the project root dir run `npm start`.
6. Open Browser at `localhost:3333`

### Level Design
We use [Tiled Map Editor](http://www.mapeditor.org/) for the level design.
When designing a level there are some things to watch out for.

**TODO:** Write docs for background sounds, spawners and config files

#### Naming Conventions
- All physic layers must be called `physics`
- All object layers for spawning objects must be called `spawnpoints`
    - In these layers the object's name must match the one in its config file (See config files)
    - the object's type must match its class
- All the sound layer must be called `sound`

#### Physics
Shiny-Wight uses two kinds of background physics:

1. A tile layer for crude background physics. It must be called 'physics'
    - The tileset used here is called `physics.png` and can be found in the `atlases` folder. This tileset must be used for now as the tile order is hardcoded, for more sophisticated physics use the object layer.
2. An object layer for more sophisticated physics.
    - The object's *name* and *type* can be arbitrary.
    - You can use *boxes* and *polygons*. *Polylines* are not supported.
    - *Polygons* must be: **convex**, have **no more than 8 corners**, **drawn clockwise**

#### Background Sounds

#### Spawners

#### Config Files
``` JSON
{
  "name": "Player",
  "velocity": 300,
  "spriteState": {
    "moving": false,
    "viewDirection": 0,
    "creationTime": "Will be overidden by `Date.Now()`",
    "animationRate": 100,
    "normal": 1
  },
  "tileSet": {
    "image": "atlases/warrior_m.png",
    "tilesX": 3,
    "tilesY": 4,
    "tileheight": 32,
    "tilewidth": 32,
    "offset": {
      "x": 16,
      "y":24
    }
  },
  "entityDef": {
    "id": "Player",
    "type": "dynamic",
    "x": "will be overidden by `@position.x`",
    "y": "will be overidden by `@position.y`",
    "halfWidth": 8,
    "halfHeight": 8,
    "damping": 0,
    "angle": 0,
    "categories": [""],
    "collidesWith": ["all"],
    "userData": {
      "id": "Player",
      "ent": "will be overidden by `this`"
    }
  }
}
```


## Used Assets
[PathAndObjects_0.png](http://opengameart.org/content/rpg-tiles-cobble-stone-paths-town-objects)
![](http://i.creativecommons.org/l/by-sa/3.0/80x15.png)

[Castle2.png](http://opengameart.org/content/castle-tiles-for-rpgs)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[mountain_landscape.png](http://opengameart.org/content/2d-lost-garden-zelda-style-tiles-resized-to-32x32-with-additions)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[wood_tileset.png](http://opengameart.org/content/2d-lost-garden-tileset-transition-to-jetrels-wood-tileset)
![](http://i.creativecommons.org/l/by-sa/3.0/80x15.png)

[magic_torrentacle.png](http://opengameart.org/content/farming-tilesets-magic-animations-and-ui-elements)
![](http://i.creativecommons.org/l/by-sa/3.0/80x15.png)

[warrior_*.png](http://opengameart.org/content/antifareas-rpg-sprite-set-1-enlarged-w-transparent-background)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[cavefuck.png](http://opengameart.org/content/cave-tileset-0)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[Tilesheet-water.png](http://opengameart.org/content/32x32-water-and-land-map-tilesets)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[fence.png](http://opengameart.org/content/lpc-farming-tilesets-magic-animations-and-ui-elements)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

[commterminal.png](http://opengameart.org/content/communication-terminal-32x32)
![](http://i.creativecommons.org/l/by/3.0/80x15.png)

## Used Sounds

* jtTheme          = [MTA][2]
* Menu             = [Wah Game Loop][2]
* snowsome_theme   = [Ice Flow][2]
* underground      = [Gagool][2]
* chasingMushrooms = [Stormfront][2]
* forestDump       = [Eternal Hope][2]
* wayToSouthPark   = [Majestic Hills][2]
* garysTheme       = [Blockman][2]
* woods            = [Senbazuru][2]
* wood             = [birds-in-spring][1]
* water            = [riviere-river][3] + [lake-waves-2][4]
* fire             = [chimney-fire][5] + [fire][6]
* level1theme      = [Somewhere Sunny (ver 2)][2]
* level2theme      = [Ambler][2]
* weichei

[1]: http://www.freesound.org/people/sverga/sounds/16726/
[2]: http://incompetech.com/
[3]: http://www.freesound.org/people/Glaneur%20de%20sons/sounds/24511/
[4]: http://www.freesound.org/people/Benboncan/sounds/67884/
[5]: http://www.freesound.org/people/reinsamba/sounds/18766/
[6]: http://www.freesound.org/people/SoundIntervention/sounds/113510/


## Features
* renders a map
* renders character
* char can move (wasd)
* char can't leave map

## Physics
box2d ([Erin Catto](http://www.gphysics.com))

## License
For the code only. For the assets see `Used Assets`

Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/
