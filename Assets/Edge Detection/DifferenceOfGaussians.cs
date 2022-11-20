using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DifferenceOfGaussians : MonoBehaviour {
    public Shader differenceOfGaussians;

    [Range(1, 10)]
    public int gaussianKernelSize = 5;

    [Range(0.1f, 5.0f)]
    public float stdev = 2.0f;

    [Range(0.1f, 5.0f)]
    public float stdevScale = 1.6f;

    public bool thresholding = true;

    [Range(0.0f, 0.1f)]
    public float threshold = 0.005f;

    public bool invert = false;

    private Material dogMat;
    
    void OnEnable() {
        dogMat = new Material(differenceOfGaussians);
        dogMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        dogMat.SetInt("_GaussianKernelSize", gaussianKernelSize);
        dogMat.SetFloat("_Sigma", stdev);
        dogMat.SetFloat("_Threshold", threshold);
        dogMat.SetInt("_Thresholding", thresholding ? 1 : 0);
        dogMat.SetInt("_Invert", invert ? 1 : 0);

        var gaussian1 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R16);
        Graphics.Blit(source, gaussian1, dogMat, 0);
        var gaussian2 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R16);
        Graphics.Blit(gaussian1, gaussian2, dogMat, 1);

        dogMat.SetFloat("_Sigma", stdev * stdevScale);

        var kgaussian1 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R16);
        Graphics.Blit(source, kgaussian1, dogMat, 0);
        var kgaussian2 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R16);
        Graphics.Blit(kgaussian1, kgaussian2, dogMat, 1);

        dogMat.SetTexture("_kGaussianTex", kgaussian2);
        dogMat.SetTexture("_GaussianTex", gaussian2);

        Graphics.Blit(source, destination, dogMat, 2);
        RenderTexture.ReleaseTemporary(gaussian1);
        RenderTexture.ReleaseTemporary(gaussian2);
        RenderTexture.ReleaseTemporary(kgaussian1);
        RenderTexture.ReleaseTemporary(kgaussian2);
    }
}
