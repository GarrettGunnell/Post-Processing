using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorBlindness : MonoBehaviour {
    public Shader colorBlindnessShader;

    private Material colorBlindMat;
    
    void Start() {
        colorBlindMat ??= new Material(colorBlindnessShader);
        colorBlindMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, colorBlindMat);
    }
}
