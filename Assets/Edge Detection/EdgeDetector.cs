using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class EdgeDetector : MonoBehaviour {
    public Shader edgeShader;
    
    public Color borderColor;

    private Material edgeMat;

    void Start() {
        edgeMat ??= new Material(edgeShader);
        edgeMat.hideFlags = HideFlags.HideAndDontSave;
        
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        edgeMat.SetColor("_BorderColor", borderColor);
        Graphics.Blit(source, destination, edgeMat);
    }
}
