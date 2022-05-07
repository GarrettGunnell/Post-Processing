using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(Tonemapper))]
[CanEditMultipleObjects]
public class ToneMapperGUI : Editor {
    SerializedProperty tonemapperShader, 
                       toneMapper,
                       Ldmax, Cmax,
                       p, hiVal,
                       Cwhite,
                       shoulderStrength, linearStrength, linearAngle, toeStrength, toeNumerator, toeDenominator, linearWhitePoint,
                       maxBrightness, contrast, linearStart, linearLength, blackTightnessShape, blackTightnessOffset;

    void OnEnable() {
        tonemapperShader = serializedObject.FindProperty("tonemapperShader");
        toneMapper = serializedObject.FindProperty("toneMapper");
        Ldmax = serializedObject.FindProperty("Ldmax");
        Cmax = serializedObject.FindProperty("Cmax");
        p = serializedObject.FindProperty("p");
        hiVal = serializedObject.FindProperty("hiVal");
        Cwhite = serializedObject.FindProperty("Cwhite");
        shoulderStrength = serializedObject.FindProperty("shoulderStrength");
        linearStrength = serializedObject.FindProperty("linearStrength");
        linearAngle = serializedObject.FindProperty("linearAngle");
        toeStrength = serializedObject.FindProperty("toeStrength");
        toeNumerator = serializedObject.FindProperty("toeNumerator");
        toeDenominator = serializedObject.FindProperty("toeDenominator");
        linearWhitePoint = serializedObject.FindProperty("linearWhitePoint");
        maxBrightness = serializedObject.FindProperty("maxBrightness");
        contrast = serializedObject.FindProperty("contrast");
        linearStart = serializedObject.FindProperty("linearStart");
        linearLength = serializedObject.FindProperty("linearLength");
        blackTightnessShape = serializedObject.FindProperty("blackTightnessShape");
        blackTightnessOffset = serializedObject.FindProperty("blackTightnessOffset");
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
            case Tonemapper.Tonemappers.ReinhardExtended:
                EditorGUILayout.Slider(Cwhite, 1.0f, 60.0f);
                break;
            case Tonemapper.Tonemappers.Hable:
                EditorGUILayout.Slider(shoulderStrength, 0.0f, 1.0f);
                EditorGUILayout.Slider(linearStrength, 0.0f, 1.0f);
                EditorGUILayout.Slider(linearAngle, 0.0f, 1.0f);
                EditorGUILayout.Slider(toeStrength, 0.0f, 1.0f);
                EditorGUILayout.Slider(toeNumerator, 0.0f, 1.0f);
                EditorGUILayout.Slider(toeDenominator, 0.0f, 1.0f);
                EditorGUILayout.Slider(linearWhitePoint, 0.0f, 60.0f);
                break;
            case Tonemapper.Tonemappers.Uchimura:
                EditorGUILayout.Slider(maxBrightness, 1.0f, 100.0f);
                EditorGUILayout.Slider(contrast, 0.0f, 5.0f);
                EditorGUILayout.Slider(linearStart, 0.0f, 1.0f);
                EditorGUILayout.Slider(linearLength, 0.01f, 0.99f);
                EditorGUILayout.Slider(blackTightnessShape, 1.0f, 3.0f);
                EditorGUILayout.Slider(blackTightnessOffset, 0.0f, 1.0f);
                break;
        }

        serializedObject.ApplyModifiedProperties();
    }
}
