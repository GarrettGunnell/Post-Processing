using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GammaCorrector : MonoBehaviour {
    public Shader gammaCorrecter;
    
    [Range(0.0f, 10.0f)]
    public float gamma = 1.0f;

    private Material gammaMat;
    
    void Start() {
        gammaMat ??= new Material(gammaCorrecter);
        gammaMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        gammaMat.SetFloat("_Gamma", gamma);
        Graphics.Blit(source, destination, gammaMat);
    }
}
