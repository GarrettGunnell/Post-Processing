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
        Ward,
        Reinhard,
        ReinhardExtended,
        Hable
    } public Tonemappers toneMapper;

    //Tumblin Rushmeier Parameters
    public float Ldmax, Cmax;

    //Schlick Parameters
    public float p, hiVal;

    //Reinhard Extended Parameters
    public float Cwhite;

    //Hable Parameters
    public float shoulderStrength, linearStrength, linearAngle, toeStrength, toeNumerator, toeDenominator, linearWhitePoint;

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
        tonemapperMat.SetFloat("_Cwhite", Cwhite);
        tonemapperMat.SetFloat("_A", shoulderStrength);
        tonemapperMat.SetFloat("_B", linearStrength);
        tonemapperMat.SetFloat("_C", linearAngle);
        tonemapperMat.SetFloat("_D", toeStrength);
        tonemapperMat.SetFloat("_E", toeNumerator);
        tonemapperMat.SetFloat("_F", toeDenominator);
        tonemapperMat.SetFloat("_W", linearWhitePoint);
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
                       p, hiVal,
                       Cwhite,
                       shoulderStrength, linearStrength, linearAngle, toeStrength, toeNumerator, toeDenominator, linearWhitePoint;

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
        }

        serializedObject.ApplyModifiedProperties();
    }
}
