using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorBlindness : MonoBehaviour {
    public Shader colorBlindnessShader;

    public enum BlindTypes {
        Normal = 0,
        Protanomaly,
        Deuteranomaly,
        Tritanomaly
    } public BlindTypes blindType;

    [Range(0.0f, 1.0f)]
    public float severity = 0.0f;

    private Material colorBlindMat;
    
    void Start() {
        colorBlindMat ??= new Material(colorBlindnessShader);
        colorBlindMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        colorBlindMat.SetFloat("_Severity", severity);

        Graphics.Blit(source, destination, colorBlindMat, (int)blindType);
    }
}
