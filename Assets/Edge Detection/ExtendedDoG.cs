using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExtendedDoG : MonoBehaviour {
    public Shader extendedDoG;
    
    [Range(0.0f, 5.0f)]
    public float structureTensorDeviation = 2.0f;

    public bool useFlow = true;

    [Range(0.0f, 5.0f)]
    public float differenceOfGaussiansDeviation = 2.0f;

    [Range(0.1f, 5.0f)]
    public float stdevScale = 1.6f;

    [Range(0.0f, 100.0f)]
    public float Sharpness = 1.0f;

    [Range(0.0f, 5.0f)]
    public float lineIntegralDeviation = 2.0f;

    public Vector2 lineConvolutionStepSizes = new Vector2(1.0f, 1.0f);

    public bool calcDiffBeforeConvolution = true;

    public enum ThresholdMode {
        NoThreshold = 0,
        Tanh,
        Quantization,
        SmoothQuantization
    } public ThresholdMode thresholdMode;

    [Range(1, 16)]
    public int quantizerStep = 2;

    [Range(0.0f, 100.0f)]
    public float whitePoint = 50.0f;

    [Range(0.0f, 10.0f)]
    public float softThreshold = 1.0f;

    public bool invert = false;

    public bool smoothEdges = true;

    [Range(0.0f, 5.0f)]
    public float edgeSmoothDeviation = 1.0f;
    
    public Vector2 edgeSmoothStepSizes = new Vector2(1.0f, 1.0f);

    private Material dogMat;
    
    void OnEnable() {
        dogMat = new Material(extendedDoG);
        dogMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        dogMat.SetFloat("_SigmaC", structureTensorDeviation);
        dogMat.SetFloat("_SigmaE", differenceOfGaussiansDeviation);
        dogMat.SetFloat("_SigmaM", lineIntegralDeviation);
        dogMat.SetFloat("_SigmaA", edgeSmoothDeviation);
        dogMat.SetFloat("_K", stdevScale);
        dogMat.SetFloat("_Tau", Sharpness);
        dogMat.SetFloat("_Phi", softThreshold);
        dogMat.SetFloat("_Threshold", whitePoint);
        dogMat.SetFloat("_Thresholds", quantizerStep);
        dogMat.SetVector("_IntegralConvolutionStepSizes", new Vector4(lineConvolutionStepSizes.x, lineConvolutionStepSizes.y, edgeSmoothStepSizes.x, edgeSmoothStepSizes.y));
        dogMat.SetInt("_Thresholding", (int)thresholdMode);
        dogMat.SetInt("_Invert", invert ? 1 : 0);
        dogMat.SetInt("_CalcDiffBeforeConvolution", calcDiffBeforeConvolution ? 1 : 0);

        var rgbToLab = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, rgbToLab, dogMat, 0);

        
        var structureTensor = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        var eigenvectors1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        var eigenvectors2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        if (useFlow || smoothEdges) {
            Graphics.Blit(rgbToLab, structureTensor, dogMat, 1);
            Graphics.Blit(structureTensor, eigenvectors1, dogMat, 2);
            Graphics.Blit(eigenvectors1, eigenvectors2, dogMat, 3);
            dogMat.SetTexture("_TFM", eigenvectors2);
        }


        var gaussian1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        var gaussian2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        if (useFlow) {    
            Graphics.Blit(rgbToLab, gaussian1, dogMat, 4);
            Graphics.Blit(gaussian1, gaussian2, dogMat, 5);
        } else {
            Graphics.Blit(rgbToLab, gaussian1, dogMat, 6);
            Graphics.Blit(gaussian1, gaussian2, dogMat, 7);
        }

        //Graphics.Blit(source, destination, dogMat, 6);
        if (smoothEdges)
            Graphics.Blit(gaussian2, destination, dogMat, 8);
        else
            Graphics.Blit(gaussian2, destination);

        RenderTexture.ReleaseTemporary(rgbToLab);
        RenderTexture.ReleaseTemporary(structureTensor);
        RenderTexture.ReleaseTemporary(eigenvectors1);
        RenderTexture.ReleaseTemporary(eigenvectors2);
        RenderTexture.ReleaseTemporary(gaussian2);
        RenderTexture.ReleaseTemporary(gaussian1);
    }
}
