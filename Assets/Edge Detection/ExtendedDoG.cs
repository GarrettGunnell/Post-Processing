using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExtendedDoG : MonoBehaviour {
    public Shader extendedDoG;

    [Range(1, 4)]
    public int superSample = 1;

    [Header("Edge Tangent Flow Settings")]
    public bool useFlow = true;

    [Range(0.0f, 5.0f)]
    public float structureTensorDeviation = 2.0f;

    [Range(0.0f, 20.0f)]
    public float lineIntegralDeviation = 2.0f;

    public Vector2 lineConvolutionStepSizes = new Vector2(1.0f, 1.0f);

    public bool calcDiffBeforeConvolution = true;

    [Header("Difference Of Gaussians Settings")]
    [Range(0.0f, 10.0f)]
    public float differenceOfGaussiansDeviation = 2.0f;

    [Range(0.1f, 5.0f)]
    public float stdevScale = 1.6f;

    [Range(0.0f, 100.0f)]
    public float Sharpness = 1.0f;

    public enum ThresholdMode {
        NoThreshold = 0,
        Tanh,
        Quantization,
        SmoothQuantization
    } 
    
    [Header("Threshold Settings")]
    public ThresholdMode thresholdMode;

    [Range(1, 16)]
    public int quantizerStep = 2;

    [Range(0.0f, 100.0f)]
    public float whitePoint = 50.0f;

    [Range(0.0f, 10.0f)]
    public float softThreshold = 1.0f;

    public bool invert = false;

    [Header("Anti Aliasing Settings")]
    public bool smoothEdges = true;

    [Range(0.0f, 10.0f)]
    public float edgeSmoothDeviation = 1.0f;
    
    public Vector2 edgeSmoothStepSizes = new Vector2(1.0f, 1.0f);

    [Header("Cross Hatch Settings")]
    public bool enableHatching = false;
    public Texture hatchTexture = null;

    [Space(10)]

    [Range(0.0f, 8.0f)]
    public float hatchResolution = 1.0f;
    [Range(-180.0f, 180.0f)]
    public float hatchRotation = 90.0f;
    
    [Space(10)]
    public bool enableSecondLayer = true;
    [Range(0.0f, 100.0f)]
    public float secondWhitePoint = 20.0f;
    [Range(0.0f, 8.0f)]
    public float hatchResolution2 = 1.0f;
    [Range(-180.0f, 180.0f)]
    public float secondHatchRotation = 60.0f;

    [Space(10)]
    public bool enableThirdLayer = true;
    [Range(0.0f, 100.0f)]
    public float thirdWhitePoint = 30.0f;
    [Range(0.0f, 8.0f)]
    public float hatchResolution3 = 1.0f;
    [Range(-180.0f, 180.0f)]
    public float thirdHatchRotation = 120.0f;

    [Space(10)]
    public bool enableFourthLayer = true;
    [Range(0.0f, 100.0f)]
    public float fourthWhitePoint = 30.0f;
    [Range(0.0f, 8.0f)]
    public float hatchResolution4 = 1.0f;
    [Range(-180.0f, 180.0f)]
    public float fourthHatchRotation = 120.0f;

    [Space(10)]
    public bool enableColoredPencil = false;
    [Range(-1.0f, 1.0f)]
    public float brightnessOffset = 0.0f;
    [Range(0.0f, 5.0f)]
    public float saturation = 1.0f;

    [Header("Blend Settings")]
    [Range(0.0f, 5.0f)]
    public float termStrength = 1.0f;

    public enum BlendMode {
        NoBlend = 0,
        Interpolate,
        TwoPointInterpolate
    } public BlendMode blendMode;

    public Color minColor = new Color(0.0f, 0.0f, 0.0f);
    public Color maxColor = new Color(1.0f, 1.0f, 1.0f);
    
    [Range(0.0f, 2.0f)]
    public float blendStrength = 1;

    private Material dogMat;
    
    void OnEnable() {
        dogMat = new Material(extendedDoG);
        dogMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        dogMat = null;
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
        dogMat.SetFloat("_Threshold2", secondWhitePoint);
        dogMat.SetFloat("_Threshold3", thirdWhitePoint);
        dogMat.SetFloat("_Threshold4", fourthWhitePoint);
        dogMat.SetFloat("_Thresholds", quantizerStep);
        dogMat.SetFloat("_BlendStrength", blendStrength);
        dogMat.SetFloat("_DoGStrength", termStrength);
        dogMat.SetFloat("_HatchTexRotation", hatchRotation);
        dogMat.SetFloat("_HatchTexRotation1", secondHatchRotation);
        dogMat.SetFloat("_HatchTexRotation2", thirdHatchRotation);
        dogMat.SetFloat("_HatchTexRotation3", fourthHatchRotation);
        dogMat.SetFloat("_HatchRes1", hatchResolution);
        dogMat.SetFloat("_HatchRes2", hatchResolution2);
        dogMat.SetFloat("_HatchRes3", hatchResolution3);
        dogMat.SetFloat("_HatchRes4", hatchResolution4);
        dogMat.SetInt("_EnableSecondLayer", enableSecondLayer ? 1 : 0);
        dogMat.SetInt("_EnableThirdLayer", enableThirdLayer ? 1 : 0);
        dogMat.SetInt("_EnableFourthLayer", enableFourthLayer ? 1 : 0);
        dogMat.SetInt("_EnableColoredPencil", enableColoredPencil ? 1 : 0);
        dogMat.SetFloat("_BrightnessOffset", brightnessOffset);
        dogMat.SetFloat("_Saturation", saturation);
        dogMat.SetVector("_IntegralConvolutionStepSizes", new Vector4(lineConvolutionStepSizes.x, lineConvolutionStepSizes.y, edgeSmoothStepSizes.x, edgeSmoothStepSizes.y));
        dogMat.SetVector("_MinColor", minColor);
        dogMat.SetVector("_MaxColor", maxColor);
        dogMat.SetInt("_Thresholding", (int)thresholdMode);
        dogMat.SetInt("_BlendMode", (int)blendMode);
        dogMat.SetInt("_Invert", invert ? 1 : 0);
        dogMat.SetInt("_CalcDiffBeforeConvolution", calcDiffBeforeConvolution ? 1 : 0);
        dogMat.SetInt("_HatchingEnabled", enableHatching ? 1 : 0);
        dogMat.SetTexture("_HatchTex", hatchTexture);

        var rgbToLab = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        Graphics.Blit(source, rgbToLab, dogMat, 0);

        
        var structureTensor = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        var eigenvectors1 = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        var eigenvectors2 = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        if (useFlow || smoothEdges) {
            Graphics.Blit(rgbToLab, structureTensor, dogMat, 1);
            Graphics.Blit(structureTensor, eigenvectors1, dogMat, 2);
            Graphics.Blit(eigenvectors1, eigenvectors2, dogMat, 3);
            dogMat.SetTexture("_TFM", eigenvectors2);
        }


        var gaussian1 = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        var gaussian2 = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        if (useFlow) {    
            Graphics.Blit(rgbToLab, gaussian1, dogMat, 4);
            Graphics.Blit(gaussian1, gaussian2, dogMat, 5);
        } else {
            Graphics.Blit(rgbToLab, gaussian1, dogMat, 6);
            Graphics.Blit(gaussian1, gaussian2, dogMat, 7);
        }

        var differenceOfGaussians = RenderTexture.GetTemporary(source.width * superSample, source.height * superSample, 0, source.format);
        if (smoothEdges)
            Graphics.Blit(gaussian2, differenceOfGaussians, dogMat, 8);
        else
            Graphics.Blit(gaussian2, differenceOfGaussians);

        dogMat.SetTexture("_DogTex", differenceOfGaussians);

        //Graphics.Blit(source, destination, dogMat, 6);
        Graphics.Blit(source, destination, dogMat, 9);

        RenderTexture.ReleaseTemporary(rgbToLab);
        RenderTexture.ReleaseTemporary(structureTensor);
        RenderTexture.ReleaseTemporary(eigenvectors1);
        RenderTexture.ReleaseTemporary(eigenvectors2);
        RenderTexture.ReleaseTemporary(gaussian2);
        RenderTexture.ReleaseTemporary(gaussian1);
        RenderTexture.ReleaseTemporary(differenceOfGaussians);
    }
}
