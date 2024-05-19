using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;

internal class ComicUnityGUI : ShaderGUI
{

    static bool ShowStylisticOptions = false;
    static bool ShowShadowOptions = false;
    static bool ShowSpecularOptions = false;
    static bool ShowMainOptions = false;
    static bool ShowShadowTextureOptions = false;

    private static class Styles
    {
        public static GUIContent uvSetLabel = EditorGUIUtility.TrTextContent("UV Set");
        public static GUIContent albedoText = EditorGUIUtility.TrTextContent("Albedo", "Albedo (RGB)");
        public static GUIContent emissionText = EditorGUIUtility.TrTextContent("Emission Color", "Emission (RGB)");
        public static GUIContent normalText = EditorGUIUtility.TrTextContent("Normal Map", "Normal (RGB)");
        public static GUIContent shadowWeightText = EditorGUIUtility.TrTextContent("Shadow Weight", "Shadow weight(R)");
        public static GUIContent shadowMaskText = EditorGUIUtility.TrTextContent("Shadow Mask", "Shadow mask(R)");
        public static GUIContent skinMaskText = EditorGUIUtility.TrTextContent("Color Shift Mask", "Color Shift Mask(R)");
        public static GUIContent smoothnessMapText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness (R)");
        public static GUIContent shadowMap1Text = EditorGUIUtility.TrTextContent("Shadow Map 1", "Shadow Texture 1 (RGB)");
        public static GUIContent shadowMap2Text = EditorGUIUtility.TrTextContent("Shadow Map 2", "Shadow Texture 2 (RGB)");


        public static string primaryMapsText = "Main";
        public static string shadowPropertiesText = "Shadow";
        public static string stylisticPropertiesText = "Color Options";
        public static string stylisticTextureColText = "Texture Colors";
        public static string stylisticShadowColText = "Shadow Colors";
        public static string specularMapsText = "Specular";
        public static string shadowTexturesText = "Shadow Textures";
        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static string advancedText = "Advanced Options";
    }

    MaterialProperty albedoMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty emission = null;
    MaterialProperty emissionHDR = null;
    MaterialProperty shadowMultiplayer = null;
    MaterialProperty shadowWeight = null;
    MaterialProperty blackValue = null;
    MaterialProperty whiteValue = null;
    MaterialProperty contrast = null;
    MaterialProperty shadowTexture1 = null;
    MaterialProperty shadowTexture2 = null;
    MaterialProperty shadowMask = null;
    MaterialProperty skinMask = null;
    MaterialProperty skinColor = null;
    MaterialProperty skinColorValue = null;
    MaterialProperty clothColor = null;
    MaterialProperty clothColorValue = null;
    MaterialProperty smoothness = null;
    MaterialProperty smoothnessMulltiplayer = null;
    MaterialProperty specular = null;
    MaterialProperty normal = null;
    MaterialProperty shadowHueSkin = null;
    MaterialProperty shadowBrightnessSkin = null;
    MaterialProperty shadowContrastSkin = null;
    MaterialProperty shadowSaturationSkin = null;
    MaterialProperty shadowHueCloth = null;
    MaterialProperty shadowBrightnessCloth = null;
    MaterialProperty shadowContrastCloth = null;
    MaterialProperty shadowSaturationCloth = null;
    MaterialProperty normalStrenth = null;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        albedoMap = FindProperty("_MainTex", props);
        albedoColor = FindProperty("_Color", props);
        emission = FindProperty("_Emission", props);
        emissionHDR = FindProperty("_EmissionHDR", props);
        normal = FindProperty("_Normal", props, false);
        normalStrenth = FindProperty("_NormalStrength", props, false);

        shadowMultiplayer = FindProperty("_ShadowMultiplier", props);
        shadowMask = FindProperty("_ShaMask", props);
        shadowWeight = FindProperty("_WShadow", props);
        blackValue = FindProperty("_ShadowWBlack", props);
        whiteValue = FindProperty("_ShadowWWhite", props);
        contrast = FindProperty("_ShadowWContrast", props);

        skinMask = FindProperty("_SkinMask", props, false);
        skinColor = FindProperty("_SkinColor", props, false);
        skinColorValue = FindProperty("_SkinColorVal", props, false);
        clothColor = FindProperty("_ClothColor", props, false);
        clothColorValue = FindProperty("_ClothColorVal", props, false);

        shadowHueSkin = FindProperty("_SkinShadowHue", props, false);
        shadowBrightnessSkin = FindProperty("_SkinShadowBrightness", props, false);
        shadowContrastSkin = FindProperty("_SkinShadowContrast", props, false);
        shadowSaturationSkin = FindProperty("_SkinShadowSaturation", props, false);

        shadowHueCloth = FindProperty("_ClothShadowHue", props, false);
        shadowBrightnessCloth = FindProperty("_ClothShadowBrightness", props, false);
        shadowContrastCloth = FindProperty("_ClothShadowContrast", props, false);
        shadowSaturationCloth = FindProperty("_ClothShadowSaturation", props, false);

        shadowTexture1 = FindProperty("_ShaTex1", props);
        shadowTexture2 = FindProperty("_ShaTex2", props);

        smoothness = FindProperty("_Smoothness", props);
        smoothnessMulltiplayer = FindProperty("_SmoothnessMulti", props);
        specular = FindProperty("_Specular", props);
    }

    //#endregion

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;


        // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
        // material to a standard shader.
        // Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)
        //if (m_FirstTimeApply)
        //{
        //    MaterialChanged(material, m_WorkflowMode);
        //    m_FirstTimeApply = false;
        //}

        ShaderPropertiesGUI(material);
    }

    //#region NOT used for NOW

    public void ShaderPropertiesGUI(Material material)
    {
        string[] keyWords = material.shaderKeywords;

        bool stylistic = keyWords.Contains("STYLISTIC_ON");
        bool normalMap = keyWords.Contains("NORMAL_ON");
        EditorGUI.BeginChangeCheck();
        stylistic = EditorGUILayout.Toggle("Stylistic", stylistic);
        normalMap = EditorGUILayout.Toggle("Normal Map", normalMap);


        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material

        {
            //BlendModePopup();

            // Primary properties

            ShowMainOptions = EditorGUILayout.Foldout(ShowMainOptions, Styles.primaryMapsText, EditorStyles.foldoutHeader);

            if (ShowMainOptions)
            {
                DoAlbedoArea();
                if(normalMap)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.normalText, normal, normalStrenth);
                }
            }


            EditorGUILayout.Space();

            ShowShadowOptions = EditorGUILayout.Foldout(ShowShadowOptions, Styles.shadowPropertiesText, EditorStyles.foldoutHeader);

            if (ShowShadowOptions)
            {

                DoShadowArea();

            }

            EditorGUILayout.Space();


            if (stylistic)
            {
                ShowStylisticOptions = EditorGUILayout.Foldout(ShowStylisticOptions, Styles.stylisticPropertiesText, EditorStyles.foldoutHeader);

                if (ShowStylisticOptions)
                {
                    GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
                    DoStylisticArea();

                }
                EditorGUILayout.Space();
            }

            ShowSpecularOptions = EditorGUILayout.Foldout(ShowSpecularOptions, Styles.specularMapsText, EditorStyles.foldoutHeader);

            if (ShowSpecularOptions)
            {

                DoSpecularArea();

            }

            EditorGUILayout.Space();

            ShowShadowTextureOptions = EditorGUILayout.Foldout(ShowShadowTextureOptions, Styles.shadowTexturesText, EditorStyles.foldoutHeader);

            if (ShowShadowTextureOptions)
            {

                DoShadowTextureArea();

            }


            EditorGUILayout.Space();

            GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
            m_MaterialEditor.EnableInstancingField();
            m_MaterialEditor.DoubleSidedGIField();
        }
        if (EditorGUI.EndChangeCheck())
        {
            // if the checkbox is changed, reset the shader keywords
            var keywords = new List<string> { stylistic ? "STYLISTIC_ON" : "STYLISTIC_OFF" };
            keywords.Add(normalMap ? "NORMAL_ON" : "NORMAL_OFF" );

            material.shaderKeywords = keywords.ToArray();
            EditorUtility.SetDirty(material);
        }
    }

    void DoAlbedoArea() //Simple Color Properties
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
        m_MaterialEditor.TexturePropertySingleLine(Styles.emissionText, emission, emissionHDR);
    }

    void DoShadowArea() //Shadow Properties
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.shadowMaskText, shadowMask);
        EditorGUILayout.Space();
        m_MaterialEditor.RangeProperty(contrast, "Shadow Factor");
        m_MaterialEditor.TexturePropertySingleLine(Styles.shadowWeightText, shadowWeight);
        m_MaterialEditor.RangeProperty(shadowMultiplayer, "Gray Multiplayer");
        m_MaterialEditor.RangeProperty(blackValue, "Black Threshold");
        m_MaterialEditor.RangeProperty(whiteValue, "White Threshold");

    }

    void DoStylisticArea() //Stylistic Properties
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.skinMaskText, skinMask);

        EditorGUILayout.Space();

        m_MaterialEditor.ColorProperty(skinColor, "Skin Color");
        m_MaterialEditor.RangeProperty(skinColorValue, "Skin Color Value");

        if (skinMask.textureValue != null)
        {
            m_MaterialEditor.ColorProperty(clothColor, "Cloth Color");
            m_MaterialEditor.RangeProperty(clothColorValue, "Cloth Color Value");
        }

        EditorGUILayout.Space();

        m_MaterialEditor.RangeProperty(shadowHueSkin, "Skin Shadow Hue");
        m_MaterialEditor.RangeProperty(shadowBrightnessSkin, "Skin Shadow Brightness");
        m_MaterialEditor.RangeProperty(shadowContrastSkin, "Skin Shadow Contrast");
        m_MaterialEditor.RangeProperty(shadowSaturationSkin, "Skin Shadow Saturation");

        if (skinMask.textureValue != null)
        {
            EditorGUILayout.Space();
            m_MaterialEditor.RangeProperty(shadowHueCloth, "Cloth Shadow Hue");
            m_MaterialEditor.RangeProperty(shadowBrightnessCloth, "Cloth Shadow Brightness");
            m_MaterialEditor.RangeProperty(shadowContrastCloth, "Cloth Shadow Contrast");
            m_MaterialEditor.RangeProperty(shadowSaturationCloth, "Cloth Shadow Saturation");
        }
    }

    void DoSpecularArea() //Specular Properities
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.smoothnessMapText, smoothness, smoothnessMulltiplayer);
        m_MaterialEditor.ColorProperty(specular, "Specular Color");
    }

    void DoShadowTextureArea() // Shadow textures
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.shadowMap1Text, shadowTexture1);
        m_MaterialEditor.TexturePropertySingleLine(Styles.shadowMap2Text, shadowTexture2);
        m_MaterialEditor.TextureScaleOffsetProperty(shadowTexture1);
    }


    //#endregion
}

