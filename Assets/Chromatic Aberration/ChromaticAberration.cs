using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChromaticAberration : MonoBehaviour {
    public Shader chromaticAberration;
    
    public bool debugMask = false;
    
    public Vector2 focalOffset = new Vector2(0.0f, 0.0f);
    public Vector2 radius = new Vector2(1.0f, 1.0f);
    
    [Range(0.01f, 5.0f)]
    public float hardness = 1.0f;
    [Range(0.01f, 5.0f)]
    public float intensity = 1.0f;
    
    public Vector3 channelOffsets = new Vector3(0.0f, 0.0f, 0.0f);

    private Material chromaticAberrationMat;
    
    void OnEnable() {
        chromaticAberrationMat = new Material(chromaticAberration);
        chromaticAberrationMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        chromaticAberrationMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        chromaticAberrationMat.SetInt("_DebugMask", debugMask ? 1 : 0);
        chromaticAberrationMat.SetVector("_FocalOffset", focalOffset);
        chromaticAberrationMat.SetVector("_Radius", radius);
        chromaticAberrationMat.SetVector("_ColorOffsets", channelOffsets);
        chromaticAberrationMat.SetFloat("_Hardness", hardness);
        chromaticAberrationMat.SetFloat("_Intensity", intensity);
        
        Graphics.Blit(source, destination, chromaticAberrationMat);
    }
}
