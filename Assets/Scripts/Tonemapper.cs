using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Tonemapper : MonoBehaviour {
    public Shader tonemapperShader;

    public enum Tonemappers {
        DebugHDR = 1,
        RGBClamp,
        TumblinRushmeier,
        Schlick,
        Ward
    } public Tonemappers toneMapper;

    //Tumblin Rushmeier Parameters
    public float Ldmax, Cmax;

    //Schlick Parameters
    public float p, hiVal;

    private Material tonemapperMat;
    private RenderTexture grayscale;
    
    void OnEnable() {
        tonemapperMat ??= new Material(tonemapperShader);
        
        if (grayscale == null) {
            grayscale = new RenderTexture(1920, 1080, 0, RenderTextureFormat.RHalf, RenderTextureReadWrite.Linear);
            grayscale.useMipMap = true;
            grayscale.Create();
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, grayscale, tonemapperMat, 0);

        tonemapperMat.SetFloat("_Ldmax", Ldmax);
        tonemapperMat.SetFloat("_Cmax", Cmax);
        tonemapperMat.SetFloat("_P", p);
        tonemapperMat.SetFloat("_HiVal", hiVal);
        tonemapperMat.SetTexture("_LuminanceTex", grayscale);


        
        Graphics.Blit(source, destination, tonemapperMat, (int)toneMapper);
    }

    void OnDisable() {
        grayscale.Release();
    }
}

[CustomEditor(typeof(Tonemapper))]
[CanEditMultipleObjects]
public class TonemapperEditor : Editor {
    SerializedProperty tonemapperShader, 
                       toneMapper,
                       Ldmax, Cmax,
                       p, hiVal;

    void OnEnable() {
        tonemapperShader = serializedObject.FindProperty("tonemapperShader");
        toneMapper = serializedObject.FindProperty("toneMapper");
        Ldmax = serializedObject.FindProperty("Ldmax");
        Cmax = serializedObject.FindProperty("Cmax");
        p = serializedObject.FindProperty("p");
        hiVal = serializedObject.FindProperty("hiVal");
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();
        EditorGUILayout.PropertyField(tonemapperShader);
        EditorGUILayout.PropertyField(toneMapper);

        Tonemapper.Tonemappers t = (Tonemapper.Tonemappers)toneMapper.enumValueIndex + 1;

        switch(t) {
            case Tonemapper.Tonemappers.TumblinRushmeier:
                EditorGUILayout.Slider(Ldmax, 1.0f, 300.0f);
                EditorGUILayout.Slider(Cmax, 1.0f, 100.0f);
                break;
            case Tonemapper.Tonemappers.Schlick:
                EditorGUILayout.Slider(p, 1.0f, 100.0f);
                EditorGUILayout.Slider(hiVal, 1.0f, 150.0f);
                break;
            case Tonemapper.Tonemappers.Ward:
                EditorGUILayout.Slider(Ldmax, 1.0f, 300.0f);
                break;
        }

        serializedObject.ApplyModifiedProperties();
    }
}
