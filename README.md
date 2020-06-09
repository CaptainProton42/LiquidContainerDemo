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

** Third pass**: Similar to the second pass but cull front faces. Recalculate the normals to simulate the surface. *Has to be drawn behind the second pass.*

** Fourth pass**: Draw the label texture and darken the edges of the container. Add some lighting effects like clearcoat to simulate the glass in front of the liquid. *Drawn in front of all other passes.*


Atrributions
------------
This repository uses  the Godot OpenVR Native module, for more information and licensing see [README_VR.md](https://github.com/CaptainProton42/LiquidContainerDemo/blob/master/README_VR.md)
