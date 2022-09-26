using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blur : MonoBehaviour {
    public Shader blurShader;

    public enum BlurOperators {
        Box = 0,
        Gaussian
    } public BlurOperators blurOperator;

    [Range(3, 20)]
    public int kernelSize = 3;

    [Range(0.1f, 10.0f)]
    public float sigma = 2.0f;

    [Range(1, 10)]
    public int blurPasses = 1;

    private Material blurMat;
    
    void OnEnable() {
        blurMat = new Material(blurShader);
        blurMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        blurMat.SetFloat("_KernelSize", kernelSize);
        blurMat.SetFloat("_Sigma", sigma);
        
        var blur1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        var blur2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

        Graphics.Blit(source, blur1, blurMat, (int)blurOperator * 2);
        Graphics.Blit(blur1, blur2, blurMat, (int)blurOperator * 2 + 1);

        for (int i = 1; i < blurPasses; ++i) {
            Graphics.Blit(blur2, blur1, blurMat, (int)blurOperator * 2);
            Graphics.Blit(blur1, blur2, blurMat, (int)blurOperator * 2 + 1);
        }

        Graphics.Blit(blur2, destination);
        RenderTexture.ReleaseTemporary(blur1);
        RenderTexture.ReleaseTemporary(blur2);
    }

    void OnDisable() {
        blurMat = null;
    }
}