using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ditherer : MonoBehaviour {
    public Shader ditherShader;

    private Material ditherMat;
    
    void Start() {
        ditherMat ??= new Material(ditherShader);
        ditherMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, ditherMat);
    }
}
