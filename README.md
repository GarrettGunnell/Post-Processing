# Post Processing Pipeline For Unity

This code accompanies my [series on Post Processing](https://www.youtube.com/playlist?list=PLUKV95Q13e_Un6ADYZ9NyWJ3W1R2cbCYv) on YouTube.

This is made for Unity 2021.3.1 using the built in pipeline.

## Disclaimer

These effects are modular only for ease of experimentation and finding what looks best for a given scene. Once desired effects have been found, many of the shaders can be condensed into a singular pass to reduce overdraw and maximize performance.

## Features

* **Fog**
* * Distance
* **Bloom**
* **Depth Based Edge Detection**
* **Color Correction**
* * Exposure
* * White Balancing
* * Contrast
* * Brightness
* * Color Filtering
* * Saturation
* **Hue Shifting**
* **Sharpness**
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

Palette Swapped (8-bit):
![color_swapped](./examples/palette_swap_grass.gif)


# References

https://catlikecoding.com/unity/tutorials/custom-srp/color-grading/ </br>
https://github.com/tizian/tonemapper </br>
https://en.wikipedia.org/wiki/Ordered_dithering