using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelArtFilter : MonoBehaviour {
    public Shader pixelArtFilter;

    private Material pixelArtMat;
    
    void Start() {
        pixelArtMat ??= new Material(pixelArtFilter);
        pixelArtMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, pixelArtMat);
    }
}
