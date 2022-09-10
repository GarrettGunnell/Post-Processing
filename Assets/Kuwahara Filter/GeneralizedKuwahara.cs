using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneralizedKuwahara : MonoBehaviour {
    public Shader kuwaharaShader;
    
    [Range(2, 20)]
    public int kernelSize = 2;
    [Range(1.0f, 18.0f)]
    public float sharpness = 8;
    [Range(1.0f, 100.0f)]
    public float hardness = 8;

    private Material kuwaharaMat;

    private RenderTexture weights, weights2;
    
    void OnEnable() {
        kuwaharaMat ??= new Material(kuwaharaShader);
        kuwaharaMat.hideFlags = HideFlags.HideAndDontSave;
        kuwaharaMat.SetInt("_KernelSize", kernelSize);
        kuwaharaMat.SetInt("_N", 8);

        weights = new RenderTexture(32, 32, 0, RenderTextureFormat.ARGBHalf);
        weights.Create();
        Graphics.Blit(weights, weights, kuwaharaMat, 0);
        weights2 = new RenderTexture(32, 32, 0, RenderTextureFormat.ARGBHalf);
        weights2.Create();
        Graphics.Blit(weights, weights2, kuwaharaMat, 1);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        kuwaharaMat.SetInt("_KernelSize", kernelSize);
        kuwaharaMat.SetInt("_N", 8);
        kuwaharaMat.SetFloat("_Q", sharpness);
        kuwaharaMat.SetFloat("_Hardness", hardness);

        kuwaharaMat.SetTexture("_K0", weights2);

        //Graphics.Blit(weights2, destination);
        Graphics.Blit(source, destination, kuwaharaMat, 2);
    }

    void OnDisable() {
        weights.Release();
        weights2.Release();
    }
}
