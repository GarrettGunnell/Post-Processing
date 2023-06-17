# Post Processing Pipeline For Unity

This code accompanies my [series on Post Processing](https://www.youtube.com/playlist?list=PLUKV95Q13e_Un6ADYZ9NyWJ3W1R2cbCYv) on YouTube.

This is made for Unity 2021.3.1 using the built in pipeline.

## Disclaimer

These effects are modular only for ease of experimentation and finding what looks best for a given scene. Once desired effects have been found, many of the shaders can be condensed into a singular pass to reduce overdraw and maximize performance.

Most of these are also not production ready, they are meant to be referenced for those looking to implement the effects themselves. While they are generally well optimized, they may not account for specific edge cases or might be lacking in desirable features.

## Features

* **Fog**
* * Distance
* **Bloom (HDR)**
* **Depth Based Edge Detection**
* **Color Correction (HDR)**
* * Exposure
* * White Balancing
* * Contrast
* * Brightness
* * Color Filtering
* * Saturation
* **Tonemapping**
* * RGB Clamp
* * Tumblin Rushmeier
* * Schlick
* * Ward
* * Reinhard
* * Reinhard Extended
* * Hable
* * Uchimura
* * Narkowicz ACES
* * Hill ACES
* **Hue Shifting**
* **Sharpness**
* * Basic Sharpening
* * Contrast Adaptive Sharpness
* **Blend Modes**
* * Add/Subtract
* * Multiply
* * Color Burn
* * Color Dodge
* * Overlay
* * Soft Light
* * Vivid Light
* **Pixel Art Effects**
* * Downsampling
* * Dithering
* * Color Palette Swapping
* **Gamma Corrector**
* **[CRT Shader](https://github.com/GarrettGunnell/CRT-Shader)** (not included with this repo)
* **Color Blindness**
* * Protanopia/Protanomaly
* * Deuteranopia/Deuteranomaly
* * Tritanopia/Tritanomaly
* **Kuwahara Filtering**
* * Basic Kuwahara
* * Generalized Kuwahara
* * Anisotropic Kuwahara w/ Polynomial Weighting
* **Zoom**
* * Anti Aliased Pixel Art Upscaler
* **Difference Of Gaussians**
* * Basic
* * Extended
* **Vignette**
* **Chromatic Aberration**
* **Blur**
* * Box
* * Gaussian

# Examples

## Unmodified

![noeffects](./examples/1_unmodified.png)

## Fog

![fog](./examples/2_fog.png)

## Bloom

![bloom](./examples/3_bloom.png)

## Color Correction (RGB Clamped)

![colorcorrect](./examples/4_colorcorrection.png)

## Hue Shifting

![hueshift](./examples/hue_shift.png)

## Sharpness

![sharpness](./examples/sharpness.png)

# Tonemapping

## Tumblin Rushmeier

![tumblinrushmeier](./examples/5_tumblinrushmeier.png)

## Schlick

![schlick](./examples/6_schlick.png)

## Ward

![ward](./examples/7_ward.png)

## Reinhard

![reinhard](./examples/8_reinhard.png)

## Reinhard Extended

![reinhardextended](./examples/9_reinhardextended.png)

## Hable

![hable](./examples/10_hable.png)

## Uchimura

![uchimura](./examples/11_uchimura.png)

## Narkowicz ACES

![narkowicz](./examples/12_narkowicz.png)

## Hill ACES

![hill](./examples/13_hillACES.png)

# Blend Modes

All examples are blended with themselves, the image is a gradient from no blending to full blend.

## Add

![addblend](./examples/Blend_Add.png)

## Subtract

![subtract](./examples/Blend_Subtract.png)

## Screen

![screen](./examples/Blend_Screen.png)

## Multiply

![multiply](./examples/Blend_Multiply.png)

## Color Dodge

![colordodge](./examples/BlendColorDodge.png)

## Color Burn

![colorburn](./examples/BlendColorBurn.png)

## Overlay

![overlay](./examples/Blend_Overlay.png)

## Soft Light

![softlight](./examples/Blend_SoftLight.png)

## Vivid Light

![vividlight](./examples/Blend_VividLight.png)

# Pixel Art

Open images in their full resolution for optimal viewing.
Sheik model is exported from melee.

![sheik](./examples/default_sheik.png)

## 2x Downsample

![downsampled_sheik](./examples/downsampled_sheik.png)

## 1x Downsample + Dither

![dithered_sheik](./examples/dithered_sheik.gif)

## 1x Downsample + Dither + Sharpness

![sharp_dither](./examples/sharp_dither.gif)

Still Frame:

![sharp_dither_still](./examples/sharp_dither_still.png)

## Color Palette Swapping

Original Colors: </br>
![dithered_grass](./examples/dithered_grass.gif)

Palette Swapped (8-bit): </br>
![color_swapped](./examples/palette_swap_grass.gif)

# Color Blindness Simulation

## Protanopia (Absent L-cone)
![protanopia](./examples/protanopia.png)

## Deuteranopia (Absent M-cone)
![deuteranopia](./examples/deuteranopia.png)

## Tritanopia (Absent S-cone)
![tritanopia](./examples/tritanopia.png)

### More Details

These shaders are useful for testing the usability of your game from the perspective of those with color blindness.

Consider the case below, with the default red and green health bars it is hard for someone who suffers from deuteranopia (the most common form of color blindness) to tell the difference between them at a glance. </br>

![league1](./examples/league1.png)

Riot Games is aware of this issue and provides a color blind mode in the options which changes ally health bars to a bright yellow, making the value difference between allies and enemies quite obvious. </br>

![league2](./examples/league2.png)

# Kuwahara Filter

## Basic
![kuwabasic](./examples/kuwaharabasic.png)

## Generalized
![kuwageneralized](./examples/kuwaharageneralized.png)

## Anisotropic
![kuwaanisotropic](./examples/kuwaharaanisotropic.png)

# References

https://catlikecoding.com/unity/tutorials/custom-srp/color-grading/ </br>
https://github.com/tizian/tonemapper </br>
https://en.wikipedia.org/wiki/Ordered_dithering </br>
https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html </br>
https://en.wikipedia.org/wiki/Kuwahara_filter
