using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneralizedKuwahara : MonoBehaviour {
    public Shader kuwaharaShader;
    
    [Range(1, 20)]
    public int kernelSize = 1;
    [Range(2, 8)]
    public int sectors = 8;
    [Range(1.0f, 18.0f)]
    public float sharpness = 8;
    [Range(1.0f, 100.0f)]
    public float hardness = 8;

    private Material kuwaharaMat;
    
    void Start() {
        Debug.LogWarning("This shader is NOT optimized and does not truly precompute the gaussian weights for ease of experimenting. Please do this yourself if you intend on using it.");
        kuwaharaMat ??= new Material(kuwaharaShader);
        kuwaharaMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        kuwaharaMat.SetInt("_KernelSize", kernelSize);
        kuwaharaMat.SetInt("_N", sectors);
        kuwaharaMat.SetFloat("_Q", sharpness);
        kuwaharaMat.SetFloat("_Hardness", hardness);

        var weights = RenderTexture.GetTemporary(32, 32, 0, source.format);
        Graphics.Blit(weights, weights, kuwaharaMat, 0);
        var weights2 = RenderTexture.GetTemporary(32, 32, 0, source.format);
        Graphics.Blit(weights, weights2, kuwaharaMat, 1);

        kuwaharaMat.SetTexture("_K0", weights2);

        //Graphics.Blit(weights2, destination);
        Graphics.Blit(source, destination, kuwaharaMat, 2);
        RenderTexture.ReleaseTemporary(weights);
        RenderTexture.ReleaseTemporary(weights2);
    }
}
