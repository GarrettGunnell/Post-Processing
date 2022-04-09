using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

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
