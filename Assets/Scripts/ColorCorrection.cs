using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ColorCorrection : MonoBehaviour {
    public Shader postProcessingShader;

    [Range(0.0f, 2.0f)]
    public float contrast;
    
    [Range(-1.0f, 1.0f)]
    public float brightness;
    
    [Range(0.0f, 5.0f)]
    public float saturation;
    
    [Range(0.0f, 5.0f)]
    public float gamma;
    
    private Material postProcessMat;

    void Start() {
        if (postProcessMat == null) {
            postProcessMat = new Material(postProcessingShader);
            postProcessMat.hideFlags = HideFlags.HideAndDontSave;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        postProcessMat.SetFloat("_Contrast", contrast);
        postProcessMat.SetFloat("_Brightness", brightness);
        postProcessMat.SetFloat("_Saturation", saturation);
        postProcessMat.SetFloat("_Gamma", gamma);
        Graphics.Blit(source, destination, postProcessMat);
    }
}