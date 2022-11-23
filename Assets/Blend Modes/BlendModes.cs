using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlendModes : MonoBehaviour {
    public Shader blendModesShader;

    public enum BlendMode {
        NoBlend = 0,
        Add,
        Subtract,
        Multiply,
        Screen,
        Overlay,
        SoftLight,
        ColorDodge,
        ColorBurn,
        VividLight
    } public BlendMode blendMode;

    public Texture blendTexture;

    public Color blendColor;

    public enum BlendType {
        BlendOnItself,
        PickedTexture,
        PickedColor
    } public BlendType blendType;
    
    [Range(0.0f, 1.0f)]
    public float strength = 0.0f;

    private Material blendModesMat;
    
    void OnEnable() {
        blendModesMat = new Material(blendModesShader);
        blendModesMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        blendModesMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        blendModesMat.SetInt("_BlendType", (int)blendType);
        blendModesMat.SetVector("_BlendColor", blendColor);
        blendModesMat.SetTexture("_BlendTex", blendTexture);
        blendModesMat.SetFloat("_Strength", strength);
        Graphics.Blit(source, destination, blendModesMat, (int)blendMode);
    }
}
