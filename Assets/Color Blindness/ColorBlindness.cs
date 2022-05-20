using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorBlindness : MonoBehaviour {
    public Shader colorBlindnessShader;

    public enum BlindTypes {
        Protanomaly = 0,
        Deuteranomaly,
        Tritanomaly
    } public BlindTypes blindType;

    [Range(0.0f, 1.0f)]
    public float severity = 0.0f;

    public bool difference = false;

    private Material colorBlindMat;
    
    void Start() {
        colorBlindMat ??= new Material(colorBlindnessShader);
        colorBlindMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        colorBlindMat.SetFloat("_Severity", severity);
        colorBlindMat.SetInt("_Difference", difference ? 1 : 0);

        Graphics.Blit(source, destination, colorBlindMat, (int)blindType);
    }
}
