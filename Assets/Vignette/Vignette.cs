using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Vignette : MonoBehaviour {
    public Shader vignette;

    
    public Color vignetteColor;
    
    public Vector2 vignetteOffset = new Vector2(0.0f, 0.0f);
    public Vector2 vignetteSize = new Vector2(1.0f, 1.0f);
    
    [Range(0.0f, 5.0f)]
    public float intensity = 1.0f;
    [Range(0.0f, 10.0f)]
    public float roundness = 1.0f;
    [Range(0.0f, 10.0f)]
    public float smoothness = 1.0f;

    private Material vignetteMat;
    
    void OnEnable() {
        vignetteMat = new Material(vignette);
        vignetteMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        vignetteMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        vignetteMat.SetVector("_VignetteColor", vignetteColor);
        vignetteMat.SetVector("_VignetteOffset", vignetteOffset);
        vignetteMat.SetVector("_VignetteSize", vignetteSize);
        vignetteMat.SetFloat("_Intensity", intensity);
        vignetteMat.SetFloat("_Roundness", roundness);
        vignetteMat.SetFloat("_Smoothness", smoothness);
        
        Graphics.Blit(source, destination, vignetteMat);
    }
}
