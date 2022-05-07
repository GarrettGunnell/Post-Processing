using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ditherer : MonoBehaviour {
    public Shader ditherShader;

    [Range(0.0f, 1.0f)]
    public float spread = 0.5f;

    [Range(2, 16)]
    public int colorCount = 2;
    [Range(0, 2)]
    public int bayerLevel = 0;

    [Range(0, 8)]
    public int downSamples = 0;

    private Material ditherMat;
    
    void Start() {
        ditherMat ??= new Material(ditherShader);
        ditherMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        ditherMat.SetFloat("_Spread", spread);
        ditherMat.SetInt("_ColorCount", colorCount);
        ditherMat.SetInt("_BayerLevel", bayerLevel);

        int width = source.width;
        int height = source.height;

        RenderTexture[] textures = new RenderTexture[8];

        RenderTexture currentSource = source;

        for (int i = 0; i < downSamples; ++i) {
            width /= 2;
            height /= 2;

            if (height < 2)
                break;

            RenderTexture currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, source.format);
            Graphics.Blit(currentSource, currentDestination);
            currentSource = currentDestination;
        }

        RenderTexture dither = RenderTexture.GetTemporary(width, height, 0, source.format);
        Graphics.Blit(currentSource, dither, ditherMat, 0);

        Graphics.Blit(dither, destination, ditherMat, 1);
        RenderTexture.ReleaseTemporary(dither);
        for (int i = 0; i < downSamples; ++i) {
            RenderTexture.ReleaseTemporary(textures[i]);
        }
    }
}
