using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : MonoBehaviour {
    public Shader bloomShader;

    [Range(0.0f, 10.0f)]
    public float threshold = 1.0f;

    [Range(0.0f, 1.0f)]
    public float softThreshold = 0.5f;

    [Range(1, 16)]
    public int downSamples = 1;

    [Range(0.01f, 2.0f)]
    public float downSampleDelta = 1.0f;

    [Range(0.01f, 2.0f)]
    public float upSampleDelta = 0.5f;

    [Range(0.0f, 10.0f)]
    public float bloomIntensity = 1;

    private Material bloomMat;

    void OnEnable() {
        if (bloomMat == null) {
            bloomMat = new Material(bloomShader);
            bloomMat.hideFlags = HideFlags.HideAndDontSave;
        }
    }

    // Bloom logic largely adapted from: https://catlikecoding.com/unity/tutorials/advanced-rendering/bloom/
    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        bloomMat.SetFloat("_Threshold", threshold);
        bloomMat.SetFloat("_SoftThreshold", softThreshold);
        bloomMat.SetFloat("_DownDelta", downSampleDelta);
        bloomMat.SetFloat("_UpDelta", upSampleDelta);
        bloomMat.SetTexture("_OriginalTex", source);
        bloomMat.SetFloat("_Intensity", bloomIntensity);

        int width = source.width / 2;
        int height = source.height / 2;

        RenderTexture[] textures = new RenderTexture[16];

        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, source.format);

        Graphics.Blit(source, currentDestination, bloomMat, 0);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        for (; i < downSamples; ++i) {
            width /= 2;
            height /= 2;

            if (height < 2)
                break;

            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, source.format);
            Graphics.Blit(currentSource, currentDestination, bloomMat, 1);
            currentSource = currentDestination;
        }

        for (i -= 2; i >= 0; --i) {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination, bloomMat, 2);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        Graphics.Blit(currentSource, destination, bloomMat, 3);
        RenderTexture.ReleaseTemporary(currentSource);
    }
}
