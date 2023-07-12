using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcerolaLensFlare : MonoBehaviour {
    public Shader lensFlareShader;

    private Material lensFlareMaterial;
    
    void OnEnable() {
        lensFlareMaterial = new Material(lensFlareShader);
        lensFlareMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        lensFlareMaterial = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, lensFlareMaterial, 0);
    }
}
