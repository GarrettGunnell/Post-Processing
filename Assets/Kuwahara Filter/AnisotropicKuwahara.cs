using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnisotropicKuwahara : MonoBehaviour {
    public Shader kuwaharaShader;
    
    [Range(1, 20)]
    public int kernelSize = 1;
    [Range(1.0f, 18.0f)]
    public float sharpness = 8;
    [Range(1.0f, 100.0f)]
    public float hardness = 8;
    [Range(0.01f, 2.0f)]
    public float alpha = 1.0f;

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
        kuwaharaMat.SetFloat("_Alpha", alpha);

        var structureTensor = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, structureTensor, kuwaharaMat, 2);
        var eigenvectors1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(structureTensor, eigenvectors1, kuwaharaMat, 3);
        var eigenvectors2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(eigenvectors1, eigenvectors2, kuwaharaMat, 4);
        kuwaharaMat.SetTexture("_TFM", eigenvectors2);

        //Graphics.Blit(weights2, destination);
        Graphics.Blit(source, destination, kuwaharaMat, 5);

        RenderTexture.ReleaseTemporary(structureTensor);
        RenderTexture.ReleaseTemporary(eigenvectors1);
        RenderTexture.ReleaseTemporary(eigenvectors2);
    }

    void OnDisable() {
        weights.Release();
        weights2.Release();
    }
}
