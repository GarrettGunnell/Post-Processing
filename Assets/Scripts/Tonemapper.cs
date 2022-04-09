using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Tonemapper : MonoBehaviour {
    public Shader tonemapperShader;

    public enum Tonemappers {
        DebugHDR = 0,
        RGBClamp,
        TumblinRushmeier,
        Schlick
    } public Tonemappers toneMapper;

    //Tumblin Rushmeier Parameters
    public float Lavg, Ldmax, Cmax;

    //Schlick Parameters
    public float p, hiVal;

    private Material tonemapperMat;
    
    void Start() {
        tonemapperMat ??= new Material(tonemapperShader);
        tonemapperMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        tonemapperMat.SetFloat("_Lavg", Lavg);
        tonemapperMat.SetFloat("_Ldmax", Ldmax);
        tonemapperMat.SetFloat("_Cmax", Cmax);
        tonemapperMat.SetFloat("_P", p);
        tonemapperMat.SetFloat("_HiVal", hiVal);

        Graphics.Blit(source, destination, tonemapperMat, (int)toneMapper);
    }
}

[CustomEditor(typeof(Tonemapper))]
[CanEditMultipleObjects]
public class TonemapperEditor : Editor {
    SerializedProperty tonemapperShader, 
                       toneMapper,
                       Lavg, Ldmax, Cmax,
                       p, hiVal;

    void OnEnable() {
        tonemapperShader = serializedObject.FindProperty("tonemapperShader");
        toneMapper = serializedObject.FindProperty("toneMapper");
        Lavg = serializedObject.FindProperty("Lavg");
        Ldmax = serializedObject.FindProperty("Ldmax");
        Cmax = serializedObject.FindProperty("Cmax");
        p = serializedObject.FindProperty("p");
        hiVal = serializedObject.FindProperty("hiVal");
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();
        EditorGUILayout.PropertyField(tonemapperShader);
        EditorGUILayout.PropertyField(toneMapper);

        Tonemapper.Tonemappers t = (Tonemapper.Tonemappers)toneMapper.enumValueIndex;

        switch(t) {
            case Tonemapper.Tonemappers.TumblinRushmeier:
                EditorGUILayout.Slider(Lavg, 0.0f, 100.0f);
                EditorGUILayout.Slider(Ldmax, 1.0f, 150.0f);
                EditorGUILayout.Slider(Cmax, 1.0f, 100.0f);
                break;
            case Tonemapper.Tonemappers.Schlick:
                EditorGUILayout.Slider(p, 1.0f, 100.0f);
                EditorGUILayout.Slider(hiVal, 1.0f, 150.0f);
                break;
        }

        serializedObject.ApplyModifiedProperties();
    }
}
