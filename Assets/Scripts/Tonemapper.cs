using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tonemapper : MonoBehaviour {
    public Shader tonemapperShader;

    public enum Tonemappers {
        RGBClamp = 0,
    } public Tonemappers toneMapper;

    private Material tonemapperMat;
    
    void Start() {
        tonemapperMat ??= new Material(tonemapperShader);
        tonemapperMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, tonemapperMat, (int)toneMapper);
    }
}
