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

    private Material blurMat;
    
    void OnEnable() {
        blurMat = new Material(blurShader);
        blurMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        blurMat.SetFloat("_KernelSize", kernelSize);
        
        var blurFirstPass = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, blurFirstPass, blurMat, (int)blurOperator);
        Graphics.Blit(blurFirstPass, destination, blurMat, (int)blurOperator + 1);
        RenderTexture.ReleaseTemporary(blurFirstPass);
    }

    void OnDisable() {
        blurMat = null;
    }
}