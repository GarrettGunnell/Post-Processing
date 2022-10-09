using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnisotropicKuwahara : MonoBehaviour {
    public Shader kuwaharaShader;
    
    [Range(2, 20)]
    public int kernelSize = 2;
    [Range(1.0f, 18.0f)]
    public float sharpness = 8;
    [Range(1.0f, 100.0f)]
    public float hardness = 8;
    [Range(0.01f, 2.0f)]
    public float alpha = 1.0f;
    [Range(0.01f, 2.0f)]
    public float zeroCrossing = 0.58f;

    public bool useZeta = false;
    [Range(0.01f, 3.0f)]
    public float zeta = 1.0f;

    [Range(1, 4)]
    public int passes = 1;

    private Material kuwaharaMat;

    void OnEnable() {
        kuwaharaMat = new Material(kuwaharaShader);
        kuwaharaMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        kuwaharaMat.SetInt("_KernelSize", kernelSize);
        kuwaharaMat.SetInt("_N", 8);
        kuwaharaMat.SetFloat("_Q", sharpness);
        kuwaharaMat.SetFloat("_Hardness", hardness);
        kuwaharaMat.SetFloat("_Alpha", alpha);
        kuwaharaMat.SetFloat("_ZeroCrossing", zeroCrossing);
        kuwaharaMat.SetFloat("_Zeta", useZeta ? zeta : 2.0f / 2.0f / (kernelSize / 2.0f));

        var structureTensor = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, structureTensor, kuwaharaMat, 0);
        var eigenvectors1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(structureTensor, eigenvectors1, kuwaharaMat, 1);
        var eigenvectors2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(eigenvectors1, eigenvectors2, kuwaharaMat, 2);
        kuwaharaMat.SetTexture("_TFM", eigenvectors2);

        RenderTexture[] kuwaharaPasses = new RenderTexture[passes];

        for (int i = 0; i < passes; ++i) {
            kuwaharaPasses[i] = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        }

        Graphics.Blit(source, kuwaharaPasses[0], kuwaharaMat, 3);

        for (int i = 1; i < passes; ++i) {
            Graphics.Blit(kuwaharaPasses[i - 1], kuwaharaPasses[i], kuwaharaMat, 3);
        }

        //Graphics.Blit(structureTensor, destination);
        Graphics.Blit(kuwaharaPasses[passes - 1], destination);

        RenderTexture.ReleaseTemporary(structureTensor);
        RenderTexture.ReleaseTemporary(eigenvectors1);
        RenderTexture.ReleaseTemporary(eigenvectors2);
        for (int i = 0; i < passes; ++i) {
            RenderTexture.ReleaseTemporary(kuwaharaPasses[i]);
        }
    }

    void OnDisable() {
        kuwaharaMat = null;
    }
}
