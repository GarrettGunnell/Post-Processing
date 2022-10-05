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
    
    [Range(1, 4)]
    public int passes = 1;

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
        
        RenderTexture[] kuwaharaPasses = new RenderTexture[passes];

        for (int i = 0; i < passes; ++i) {
            kuwaharaPasses[i] = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        }

        Graphics.Blit(source, kuwaharaPasses[0], kuwaharaMat, 2);

        for (int i = 1; i < passes; ++i) {
            Graphics.Blit(kuwaharaPasses[i - 1], kuwaharaPasses[i], kuwaharaMat, 2);
        }

        Graphics.Blit(kuwaharaPasses[passes - 1], destination);
        //Graphics.Blit(weights2, destination);
        for (int i = 0; i < passes; ++i) {
            RenderTexture.ReleaseTemporary(kuwaharaPasses[i]);
        }
    }

    void OnDisable() {
        weights.Release();
        weights2.Release();
        kuwaharaMat = null;
    }
}
