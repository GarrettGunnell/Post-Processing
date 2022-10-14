using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Zoom : MonoBehaviour {
    public Shader zoomShader;

    public enum ZoomMode {
        Point = 0,
        PixelArtAntiAlias,
        Linear
    } public ZoomMode zoomMode;
    
    [Range(0.0f, 2.0f)]
    public float zoom = 1.0f;

    public Vector2 offset;

    private Material zoomMat;
    
    void OnEnable() {
        zoomMat = new Material(zoomShader);
        zoomMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnDisable() {
        zoomMat = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        zoomMat.SetFloat("_Zoom", zoom);
        zoomMat.SetInt("_ZoomMode", (int)zoomMode);
        zoomMat.SetVector("_Offset", offset);
        
        Graphics.Blit(source, destination, zoomMat);
    }
}
