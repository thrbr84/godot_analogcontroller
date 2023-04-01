# Godot - Analog Controller

- Developed for Godot 4
- [Click here to get the version compatible to Godot 3](https://github.com/thiagobruno/godot_analogcontroller/releases/tag/GodotV3)
- [Documentação em Português](README_PT-BR.md)

A virtual analog control for the directions:
- 360º (Vector2), 
- 2_H (Horizontal), 
- 2_V (Vertical), 
- 4 (left, right, up, down)
- 8 (left["up, down"], right["up, down"], up, down)

----------

### Demonstration (PT-BR)
- https://www.youtube.com/watch?v=plHDdyC_suc

[![Video with explanation in Portuguese](https://img.youtube.com/vi/plHDdyC_suc/0.jpg)](https://www.youtube.com/watch?v=plHDdyC_suc)

----------

##### Example
In the example project, I show two examples of how to use a player with movements in Vector2, and with movements in predefined directions (alias).

----------

##### Configure the Addon
- Download the file [addon/analog.zip](addon/analog_controller.zip)
- Place in your project's "addon" folder
- Access the Project Settings > Plugin and enable the "AnalogController" plugin

----------

##### Signals

The AnalogController emits three signals!

- analogChange(force, pos)
- analogPressed
- analogRelease

----------

To 360º type, the signal ```analogChange(force, pos)``` the "force" parameter is a value (float) returned from "0.0 to 1.0"

----------

To 2,4 e 8 (alias directions) force returns a normalized Vector2() with the calculated analog strength!
And in the "pos" parameter, the position alias is returned ... "right, left, etc ..."

----------

##### Node Settings


- ```(boolean) isDynamicallyShowing``` = The analog controller must appear dynamically, or fixed on the screen
- ```(typesAnalog) typeAnalogic``` = DIRECTION_2_H, DIRECTION_2_V, DIRECTION_4, DIRECTION_8, DIRECTION_360
- ```(float,0.00,1.0) var smoothClick``` = Time for the control to appear when clicking on the analog stick
- ```(float,0.00,1.0) var smoothRelease``` = Time for the control to be hidden when releasing the analog
- ```(Texture) var bigBallTexture``` = You can upload a texture of your choice to the larger ball (base) of the analog
- ```(Texture) var smallBallTexture``` = You can load a texture of your choice for the smaller analog ball
- ```(Dictionary) directionsResult``` = Here you can define the nicknames you want to return in each direction except for the 360º type

----------

### ...
Will you use this code commercially? Rest assured you can use it freely and without having to mention anything, of course I will be happy if you at least remember the help and share it with friends, lol. If you feel at heart, consider buying me a coffee :heart: -> https://ko-fi.com/thsbruno

