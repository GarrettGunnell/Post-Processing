using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tonemapper : MonoBehaviour {
    public Shader tonemapperShader;

    public enum Tonemappers {
        DebugHDR = 1,
        RGBClamp,
        TumblinRushmeier,
        Schlick,
        Ward,
        Reinhard,
        ReinhardExtended,
        Hable,
        Uchimura,
        NarkowiczACES,
        HillACES
    } public Tonemappers toneMapper;

    //Tumblin Rushmeier Parameters
    public float Ldmax, Cmax;

    //Schlick Parameters
    public float p, hiVal;

    //Reinhard Extended Parameters
    public float Cwhite;

    //Hable Parameters
    public float shoulderStrength, linearStrength, linearAngle, toeStrength, toeNumerator, toeDenominator, linearWhitePoint;

    //Uchimura Parameters
    public float maxBrightness, contrast, linearStart, linearLength, blackTightnessShape, blackTightnessOffset;

    private Material tonemapperMat;
    private RenderTexture grayscale;
    
    void OnEnable() {
        tonemapperMat = new Material(tonemapperShader);
        
        if (grayscale == null) {
            grayscale = new RenderTexture(1920, 1080, 0, RenderTextureFormat.RHalf, RenderTextureReadWrite.Linear);
            grayscale.useMipMap = true;
            grayscale.Create();
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, grayscale, tonemapperMat, 0);

        tonemapperMat.SetFloat("_Ldmax", Ldmax);
        tonemapperMat.SetFloat("_Cmax", Cmax);
        tonemapperMat.SetFloat("_P", p);
        tonemapperMat.SetFloat("_HiVal", hiVal);
        tonemapperMat.SetFloat("_Cwhite", Cwhite);
        tonemapperMat.SetFloat("_A", shoulderStrength);
        tonemapperMat.SetFloat("_B", linearStrength);
        tonemapperMat.SetFloat("_C", linearAngle);
        tonemapperMat.SetFloat("_D", toeStrength);
        tonemapperMat.SetFloat("_E", toeNumerator);
        tonemapperMat.SetFloat("_F", toeDenominator);
        tonemapperMat.SetFloat("_W", linearWhitePoint);
        tonemapperMat.SetFloat("_M", maxBrightness);
        tonemapperMat.SetFloat("_a", contrast);
        tonemapperMat.SetFloat("_m", linearStart);
        tonemapperMat.SetFloat("_l", linearLength);
        tonemapperMat.SetFloat("_c", blackTightnessShape);
        tonemapperMat.SetFloat("_b", blackTightnessOffset);
        
        tonemapperMat.SetTexture("_LuminanceTex", grayscale);

        Graphics.Blit(source, destination, tonemapperMat, (int)toneMapper);
    }

    void OnDisable() {
        tonemapperMat = null;
        grayscale.Release();
    }
}
