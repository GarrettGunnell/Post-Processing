using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlendModes : MonoBehaviour {
    public Shader blendModesShader;

    public enum BlendMode {
        NoBlend = 0,
        Multiply,
        Screen,
        Overlay,
        HardLight,
        SoftLight,
        ColorBurn
    } public BlendMode blendMode;
    
    [Range(0.0f, 1.0f)]
    public float strength = 0.0f;

    private Material blendModesMat;
    
    void Start() {
        blendModesMat ??= new Material(blendModesShader);
        blendModesMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        blendModesMat.SetFloat("_Strength", strength);
        Graphics.Blit(source, destination, blendModesMat, (int)blendMode);
    }
}
