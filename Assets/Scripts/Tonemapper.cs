using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Tonemapper : MonoBehaviour {
    public Shader tonemapperShader;

    public enum Tonemappers {
        DebugHDR = 0,
        RGBClamp
    } public Tonemappers toneMapper;

    private Material tonemapperMat;
    
    void Start() {
        tonemapperMat ??= new Material(tonemapperShader);
        tonemapperMat.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, tonemapperMat, (int)toneMapper);
    }
}

[CustomEditor(typeof(Tonemapper))]
[CanEditMultipleObjects]
public class TonemapperEditor : Editor {
    SerializedProperty tonemapperShader;
    SerializedProperty toneMapper;

    void OnEnable() {
        tonemapperShader = serializedObject.FindProperty("tonemapperShader");
        toneMapper = serializedObject.FindProperty("toneMapper");
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();
        EditorGUILayout.PropertyField(tonemapperShader);
        EditorGUILayout.PropertyField(toneMapper);
        serializedObject.ApplyModifiedProperties();
    }
}
