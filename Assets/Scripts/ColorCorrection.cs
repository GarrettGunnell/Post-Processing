using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ColorCorrection : MonoBehaviour {
    public Shader postProcessingShader;

    [Range(0.0f, 10.0f)]
    public float exposure = 1.0f;

    [Range(-100.0f, 100.0f)]
    public float temperature, tint;

    [Range(0.0f, 2.0f)]
    public float contrast;
    
    [Range(-1.0f, 1.0f)]
    public float brightness;

    [ColorUsageAttribute(false, true)]
    public Color colorFilter;
    
    [Range(0.0f, 5.0f)]
    public float saturation;
    
    private Material postProcessMat;

    void Start() {
        postProcessMat ??= new Material(postProcessingShader);
        postProcessMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        postProcessMat.SetFloat("_Exposure", exposure);
        postProcessMat.SetFloat("_Temperature", temperature / 100.0f);
        postProcessMat.SetFloat("_Tint", tint / 100.0f);
        postProcessMat.SetFloat("_Contrast", contrast);
        postProcessMat.SetFloat("_Brightness", brightness);
        postProcessMat.SetVector("_ColorFilter", colorFilter);
        postProcessMat.SetFloat("_Saturation", saturation);
        Graphics.Blit(source, destination, postProcessMat);
    }
}