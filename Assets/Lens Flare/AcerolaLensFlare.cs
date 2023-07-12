using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcerolaLensFlare : MonoBehaviour {
    public Shader lensFlareShader;

    [Range(0.0f, 1.0f)]
    public float threshold = 0.5f;

    [Range(1, 32)]
    public int sampleCount = 16;

    [Range(0.0f, 0.1f)]
    public float sampleDistance = 0.01f;
    [Range(0.0f, 1.0f)]
    public float haloRadius = 1.0f;
    [Range(0.0f, 1.0f)]
    public float haloThickness = 0.5f;

    public Vector3 channelOffsets = new Vector3(0.0f, 0.0f, 0.0f);

    [Range(1, 20)]
    public int kernelSize = 2;

    [Range(0.0f, 10.0f)]
    public float sigma = 1.0f;

    private Material lensFlareMaterial;
    
    void OnEnable() {
        lensFlareMaterial = new Material(lensFlareShader);
        lensFlareMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        lensFlareMaterial = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        lensFlareMaterial.SetFloat("_Threshold", threshold);
        lensFlareMaterial.SetVector("_ColorOffsets", channelOffsets);
        lensFlareMaterial.SetInt("_KernelSize", kernelSize);
        lensFlareMaterial.SetFloat("_Sigma", sigma);
        lensFlareMaterial.SetInt("_SampleCount", sampleCount);
        lensFlareMaterial.SetFloat("_SampleDistance", sampleDistance);
        lensFlareMaterial.SetFloat("_HaloRadius", haloRadius);
        lensFlareMaterial.SetFloat("_HaloThickness", haloThickness);
        var noise = RenderTexture.GetTemporary(256, 64, 0, source.format);
        Graphics.Blit(noise, noise, lensFlareMaterial, 6);
        lensFlareMaterial.SetTexture("_NoiseTex", noise);
        var downsample = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        var featureGen = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        var chromatic = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        var blur1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        var blur2 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        Graphics.Blit(source, downsample, lensFlareMaterial, 0);
        Graphics.Blit(downsample, featureGen, lensFlareMaterial, 1);
        Graphics.Blit(featureGen, chromatic, lensFlareMaterial, 2);
        Graphics.Blit(chromatic, blur1, lensFlareMaterial, 3);
        Graphics.Blit(blur1, blur2, lensFlareMaterial, 4);
        lensFlareMaterial.SetTexture("_LensFlareTex", blur2);
        Graphics.Blit(source, destination, lensFlareMaterial, 5);
        RenderTexture.ReleaseTemporary(downsample);
        RenderTexture.ReleaseTemporary(featureGen);
        RenderTexture.ReleaseTemporary(chromatic);
        RenderTexture.ReleaseTemporary(blur1);
        RenderTexture.ReleaseTemporary(blur2);
        RenderTexture.ReleaseTemporary(noise);
    }
}
