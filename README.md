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
  "VELOCITY": 300,
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

## Features
* renders a map
* renders character
* char can move (wasd)
* char can't leave map

## Physics
box2d ([Erin Catto](http://www.gphysics.com))

## License
For the code only. For the assets see `Used Assets`

![license](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/).
