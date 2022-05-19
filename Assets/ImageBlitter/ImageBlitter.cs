using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageBlitter : MonoBehaviour {

    public Texture image;

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(image ? image : source, destination);
    }
}
