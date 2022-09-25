using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Kuwahara : MonoBehaviour {
    public Shader kuwaharaShader;
    
    [Range(1, 20)]
    public int kernelSize = 1;

    private Material kuwaharaMat;
    
    void Start() {
        kuwaharaMat ??= new Material(kuwaharaShader);
        kuwaharaMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        kuwaharaMat.SetFloat("_KernelSize", kernelSize);
        Graphics.Blit(source, destination, kuwaharaMat);
    }

    void OnDisable() {
        kuwaharaMat = null;
    }
}