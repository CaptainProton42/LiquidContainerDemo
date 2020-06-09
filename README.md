# Liquid Container Demo

This repository contains a demo scene for a liquid-in-container shader I made in the Godot Engine.
The containers use tool scripts and and can thus be run directly from the editor or the scene can be started in OpenVR.

![](https://raw.githubusercontent.com/CaptainProton42/LiquidContainerDemo/media/demo_gif1.gif)

Instructions
------------

Open `scenes/Demo.tscn` to view the demo scene and play the project to run it in VR.

Material properties can be edited by changing the exported variables of the *mesh* script.

![](https://raw.githubusercontent.com/CaptainProton42/LiquidContainerDemo/media/demo_gif2.gif)

Material
--------

The material is located in `assets/materials/LiquidContainer.tres` and the shaders used for each pass are located in `assets/shaders`.

The material renders in four passes:

**First pass**: Render the back faces of the mesh and add some lighting to simulate the glass. *Drawn behind all other passes.*

**Second pass**: Move the vertices of the model inwards a bit to simulate glass thickness and discard all fragments above the liquid line. Add some lighting and bubbles.

In order to obtain the position in the container but rotated to world coordinates (to keep the liquid aligned with the world horizon) we do (where `pos` is a varying)

```
pos = mat3(WORLD_MATRIX)*VERTEX;
```

The height above which to discard is defined by the `varying` `liquid_line` as follows:

```
float d = dot(vec3(WORLD_MATRIX[0][1], WORLD_MATRIX[1][1], WORLD_MATRIX[2][1]), vec3(0.0f, 1.0f, 0.0f));
float m = lerp(width, height, abs(d));
  
liquid_line = (fill_amount - 0.5f) * m
        + wave_intensity * length(coeff) * (texture(waves_noise, 2.0*pos.xz + 0.5*TIME * vec2(1.0, 1.0)).r - 0.5f
                              + texture(waves_noise, 2.0*pos.xz - 0.5*TIME * vec2(1.0, 1.0)).g - 0.5f)
        + dot(pos.xz, coeff);
```

We lerp between the width and the height of the container depending on the orientation of its z axis. This allows more realistic simulation of a constant liquid volume. Then, we add a noise texture (in this case Worley noise) moved over time and superimposed to create the smaller waves and finally the incline of the liquid surface based on the current coefficients `coeff` of the incline (which are set by the script).

Then, in the fragment shader we do

```
if (pos.y > liquid_line) discard;
```

**Third pass**: Similar to the second pass but cull front faces. Recalculate the normals to simulate the surface. *Has to be drawn behind the second pass.*

**Fourth pass**: Draw the label texture and darken the edges of the container. Add some lighting effects like clearcoat to simulate the glass in front of the liquid. *Drawn in front of all other passes.*

About
-----

You can find be on Twitter as [@CaptainProton42](https://twitter.com/CaptainProton42) and on Reddit as [u/CaptainProton42](https://www.reddit.com/user/CaptainProton42).


Atrributions
------------
This repository uses  the Godot OpenVR Native module, for more information and licensing see [README_VR.md](https://github.com/CaptainProton42/LiquidContainerDemo/blob/master/README_VR.md)
