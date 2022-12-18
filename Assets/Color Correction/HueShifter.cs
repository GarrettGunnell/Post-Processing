using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class HueShifter : MonoBehaviour {
    public Shader hueShiftShader;

    [Range(0.0f, 1.0f)]
    public float shift;
    
    private Material hueShiftMat;

    void OnEnable() {
        hueShiftMat ??= new Material(hueShiftShader);
        hueShiftMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        hueShiftMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        hueShiftMat.SetFloat("_HueShift", shift);
        Graphics.Blit(source, destination, hueShiftMat);
    }
}