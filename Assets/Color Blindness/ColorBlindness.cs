using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorBlindness : MonoBehaviour {
    public Shader colorBlindnessShader;

    public enum BlindTypes {
        Normal = 0,
        Protanopia,
        Protanomaly,
        Deuteranopia,
        Deuteranomaly,
        Tritanopia,
        Tritanomaly,
        Achromatopsia,
        Achromatomaly
    } public BlindTypes blindType;

    private Material colorBlindMat;
    
    void Start() {
        colorBlindMat ??= new Material(colorBlindnessShader);
        colorBlindMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, colorBlindMat, (int)blindType);
    }
}
