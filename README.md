# Post Processing Pipeline For Unity

This code accompanies my [series on Post Processing](https://www.youtube.com/playlist?list=PLUKV95Q13e_Un6ADYZ9NyWJ3W1R2cbCYv) on YouTube.

## Features

* Fog
* Bloom
* Depth Based Edge Detection
* Color Correction
* * Exposure
* * White Balancing
* * Contrast
* * Brightness
* * Color Filtering
* * Saturation
* Sharpness
* Tonemapping
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
* Pixel Art Effects
* * Downscampling
* * Dithering
* * Color Palette Swapping
* Gamma Corrector

# Examples

## Unmodified

![noeffects](./examples/1_unmodified.png)

## Fog

![fog](./examples/2_fog.png)

## Bloom

![bloom](./examples/3_bloom.png)

## Color Correction (RGB Clamped)

![colorcorrect](./examples/4_colorcorrection.png)

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

![sheik](/examples/default_sheik.png)

## 2x Downsample

![downsampled_sheik](/examples/downsampled_sheik.png)

## 1x Downsample + Dither

![dithered_sheik](/examples/dithered_sheik.gif)

## Color Palette Swapping

Original Colors: </br>
![dithered_grass](/examples/dithered_grass.gif)

Palette Swapped (8-bit):
![color_swapped](/examples/palette_swap_grass.gif)


# References

https://catlikecoding.com/unity/tutorials/custom-srp/color-grading/ </br>
https://github.com/tizian/tonemapper </br>
https://en.wikipedia.org/wiki/Ordered_dithering