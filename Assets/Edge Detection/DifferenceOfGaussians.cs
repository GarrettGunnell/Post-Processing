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

    [Range(0.01f, 5.0f)]
    public float tau = 1.0f;

    public bool thresholding = true;

    public bool tanh = false;

    [Range(0.01f, 100.0f)]
    public float phi = 1.0f;

    [Range(-1.0f, 1.0f)]
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
        dogMat.SetFloat("_K", stdevScale);
        dogMat.SetFloat("_Tau", tau);
        dogMat.SetFloat("_Phi", phi);
        dogMat.SetFloat("_Threshold", threshold);
        dogMat.SetInt("_Thresholding", thresholding ? 1 : 0);
        dogMat.SetInt("_Invert", invert ? 1 : 0);
        dogMat.SetInt("_Tanh", tanh ? 1 : 0);

        var gaussian1 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.RG32);
        Graphics.Blit(source, gaussian1, dogMat, 0);
        var gaussian2 = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.RG32);
        Graphics.Blit(gaussian1, gaussian2, dogMat, 1);

        dogMat.SetTexture("_GaussianTex", gaussian2);

        Graphics.Blit(source, destination, dogMat, 2);
        RenderTexture.ReleaseTemporary(gaussian1);
        RenderTexture.ReleaseTemporary(gaussian2);
    }
}
