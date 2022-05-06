using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ditherer : MonoBehaviour {
    public Shader ditherShader;

    [Range(0.0f, 1.0f)]
    public float spread = 0.5f;

    [Range(2, 8)]
    public int colorCount = 2;
    [Range(0, 2)]
    public int bayerLevel = 0;

    private Material ditherMat;
    
    void Start() {
        ditherMat ??= new Material(ditherShader);
        ditherMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        ditherMat.SetFloat("_Spread", spread);
        ditherMat.SetInt("_ColorCount", colorCount);
        ditherMat.SetInt("_BayerLevel", bayerLevel);
        Graphics.Blit(source, destination, ditherMat);
    }
}
