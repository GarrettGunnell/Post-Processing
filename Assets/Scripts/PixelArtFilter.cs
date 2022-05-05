using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelArtFilter : MonoBehaviour {
    public Shader pixelArtFilter;

    [Range(1, 8)]
    public int downSamples = 1;

    private Material pixelArtMat;
    
    void Start() {
        pixelArtMat ??= new Material(pixelArtFilter);
        pixelArtMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        int width = source.width / 2;
        int height = source.height / 2;

        RenderTexture[] textures = new RenderTexture[16];

        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, source.format);

        Graphics.Blit(source, currentDestination, pixelArtMat);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        for (; i < downSamples; ++i) {
            width /= 2;
            height /= 2;

            if (height < 2)
                break;

            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, source.format);
            Graphics.Blit(currentSource, currentDestination, pixelArtMat);
            currentSource = currentDestination;
        }

        for (i -= 2; i >= 0; --i) {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination, pixelArtMat);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        Graphics.Blit(currentSource, destination, pixelArtMat);
        RenderTexture.ReleaseTemporary(currentSource);
    }
}
