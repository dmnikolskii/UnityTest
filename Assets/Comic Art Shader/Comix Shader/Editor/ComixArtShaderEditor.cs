
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace Eugeen.ComixShader
{


    public class ComixArtShaderEditor : ShaderGUI
    {
        Material _target;
        MaterialEditor _editor;
        MaterialProperty[] _properties;

        public enum CullMode
        {
            Both,
            Back,
            Front
        }


        enum RenderingMode
        {
            Opaque, Cutout, Fade
        }
        bool _showAlphaCutoff;

        static bool _texturesFoldout = false;

        static bool _lineArtFoldout = false;
        bool useLineArt;
        bool useProcLineArt;
        bool overrideShadowColor;
        bool invertInShadows;

        static bool _shadingFoldout = false;
        bool _useScreenSpace = false;
        bool _crosshatching = false;
        bool _compensateDistance = false;


        static bool _shadowsFoldout = false;
        static bool _highligthFoldout = false;
        bool _useHighlight = false;

        static bool _fresnelFoldout = false;
        bool _useFresnel = false;
        bool _realisticFresnel = false;

        static bool _addLightsFoldout = false;


        static bool _outlineFoldout = false;
        bool _useOutline = false;

        #region Styles

        static Color _mapsFoldoutColor;
        static Color _mapsBGColor;

        #endregion

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            _target = materialEditor.target as Material;
            _editor = materialEditor;
            _properties = properties;

            //DrawRenderingSettings();

            MaterialProperty cull = FindProperty("_Cull");
            //_editor.DefaultShaderProperty(cull, "Culling Mode");

            float propertyHeight = _editor.GetPropertyHeight(cull, cull.displayName);
            Rect controlRect = EditorGUILayout.GetControlRect(true, propertyHeight, EditorStyles.layerMaskField);
            _editor.ShaderProperty(controlRect, cull, cull.displayName);
            

            DrawMaps();
            EditorGUILayout.Separator();

            DrawLineArt();
            EditorGUILayout.Separator();

            DrawShading();
            EditorGUILayout.Separator();

            DrawShadows();
            EditorGUILayout.Separator();

            DrawHighlight();
            EditorGUILayout.Separator();

            DrawAdditionalLights();
            EditorGUILayout.Separator();

            DrawFresnel();
            EditorGUILayout.Separator();

            //DrawOutline();
            //EditorGUILayout.Separator();



            if (SupportedRenderingFeatures.active.editableMaterialRenderQueue)
            {
                _editor.RenderQueueField();
            }

            _editor.EnableInstancingField();
            //_editor.DoubleSidedGIField();


            _editor.SaveChanges();
            //base.OnGUI(materialEditor, properties);
        }

        void DrawRenderingSettings()
        {

            var cullingProp = FindProperty("_Cull");
            cullingProp.floatValue =
                (float)(CullMode)EditorGUILayout.EnumPopup(new GUIContent("Render face"),
                    (CullMode)cullingProp.floatValue);


            //RenderingMode mode = RenderingMode.Opaque;
            //_showAlphaCutoff = false;
            //if (_target.IsKeywordEnabled("_RENDERING_CUTOUT"))
            //{
            //    mode = RenderingMode.Cutout;
            //    _showAlphaCutoff = true;
            //}

            //EditorGUI.BeginChangeCheck();
            //mode = (RenderingMode)EditorGUILayout.EnumPopup(
            //    MakeLabel("Rendering Mode"), mode
            //);
            //if (EditorGUI.EndChangeCheck())
            //{
            //    SetKeyword("_RENDERING_CUTOUT", mode == RenderingMode.Cutout);
            //    SetKeyword("_RENDERING_FADE", mode == RenderingMode.Fade);
            //    RenderingSettings settings = RenderingSettings.modes[(int)mode];
            //    foreach (Material m in _editor.targets)
            //    {
            //        m.renderQueue = (int)settings.queue;
            //        m.SetOverrideTag("RenderType", settings.renderType);
            //    }
            //}
        }

        void DrawMaps()
        {
            if (_mapsFoldoutColor == null)
            {
                _mapsFoldoutColor = new Color(1f, 0.5f, 0.5f, 0.5f);
            }


            GUIStyle style = new GUIStyle();

            //style.normal.background = BackgroundStyle.GetTexture(_mapsFoldoutColor);
            //style.active.background = BackgroundStyle.GetTexture(_mapsFoldoutColor);
            //style.hover.background = BackgroundStyle.GetTexture(_mapsFoldoutColor);
            //EditorGUILayout.BeginVertical(style);

            _texturesFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_texturesFoldout, "Textures");

            //EditorGUILayout.EndVertical();


            if (_texturesFoldout)
            {
                if (_mapsBGColor == null)
                {
                    _mapsBGColor = _mapsFoldoutColor;
                    _mapsFoldoutColor.a = 0.25f;
                }
                //BackgroundStyle.Get(_mapsBGColor)
                EditorGUILayout.BeginVertical();

                MaterialProperty mainTex = FindProperty("_MainTex");
                _editor.TexturePropertySingleLine(MakeLabel(mainTex, "Albedo (RGB)"), mainTex, FindProperty("_Tint"));
                _editor.TextureScaleOffsetProperty(mainTex);


                //_editor.RangeProperty(FindProperty("_AlphaCutoff"), "Alpha Cutoff");

                MaterialProperty normal = FindProperty("_NormalMap");
                MaterialProperty normalStrength = FindProperty("_NormalStrength");
                _editor.TexturePropertySingleLine(MakeLabel(normal), normal);
                if (normal.textureValue)
                {
                    _editor.FloatProperty(normalStrength, normalStrength.displayName);
                }
                _editor.TextureScaleOffsetProperty(normal);
                EditorGUILayout.EndVertical();

            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }

        void DrawLineArt()
        {
            _lineArtFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_lineArtFoldout, "Line Art", EditorStyles.foldoutHeader);

            if (_lineArtFoldout)
            {

                EditorGUI.BeginChangeCheck();

                ShaderProperty("_UseLineArt", "Enable Line Art");
                useLineArt = _target.IsKeywordEnabled("_USE_LINEART");
                //useLineArt = EditorGUILayout.Toggle(MakeLabel("Enable Line Art"), useLineArt);

                if (useLineArt)
                {
                    EditorGUI.indentLevel += 1;

                    EditorGUI.BeginChangeCheck();
                    ShaderProperty("_UseProceduralLineArt", "Procedural (Expensive)");


                    useProcLineArt = _target.IsKeywordEnabled("_USE_PROC_LINEART");
                    //useProcLineArt = EditorGUILayout.Toggle(MakeLabel("Use Procedural"), useProcLineArt);
                    if (!useProcLineArt)
                    {
                        _editor.TexturePropertySingleLine(MakeLabel("Mask"), FindProperty("_LineArtMask"));
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        RecordAction("Use Procedural");
                        
                        SetKeyword("_USE_PROC_LINEART", useProcLineArt);

                    }

                    _editor.ColorProperty(FindProperty("_LineArtMainColor"), "Main Color");

                    _editor.FloatProperty(FindProperty("_LineArtStrength"), "Line Art Strength");

                    DrawVector4(FindProperty("_LineArtSmoothstepValues"), "Minimum", "Maximum");

                    EditorGUI.BeginChangeCheck();

                    ShaderProperty("_OverrideLineArtShadowColor", "Override Color In Shadows");
                    overrideShadowColor = _target.IsKeywordEnabled("_OVERRIDE_LINEART_SHADOW");
                    //overrideShadowColor = EditorGUILayout.Toggle(MakeLabel("Override Color In Shadows"), overrideShadowColor);

                    if (EditorGUI.EndChangeCheck())
                    {
                        RecordAction("Override Color In Shadows");
                        SetKeyword("_OVERRIDE_LINEART_SHADOW", overrideShadowColor);
                    }
                    if (overrideShadowColor)
                    {
                        EditorGUI.BeginChangeCheck();
                        ShaderProperty("_InvertLineArtShadowColor", "Invert In Shadows");
                        invertInShadows = _target.IsKeywordEnabled("_INVERT_LINE_SHADOW_COLOR");
                        EditorGUI.indentLevel += 1;
                        //invertInShadows = EditorGUILayout.Toggle(MakeLabel("Invert In Shadows"), invertInShadows);

                        if (!invertInShadows)
                        {
                            _editor.ColorProperty(FindProperty("_LineArtShadowColor"), "Color In Shadows");
                        }
                        EditorGUI.indentLevel -= 1;
                        if (EditorGUI.EndChangeCheck())
                        {
                            RecordAction("Invert In Shadows");

                            SetKeyword("_INVERT_LINE_SHADOW_COLOR", invertInShadows);
                        }
                    }

                    EditorGUI.indentLevel -= 1;

                }



                if (EditorGUI.EndChangeCheck())
                {
                    RecordAction("Use Line Art");
                    SetKeyword("_USE_LINEART", useLineArt);
                }

            }

            EditorGUILayout.EndFoldoutHeaderGroup();
        }

        void DrawShading()
        {
            _shadingFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_shadingFoldout, "Shading", EditorStyles.foldoutHeader);
            if (_shadingFoldout)
            {
                #region Screen Space
                EditorGUI.BeginChangeCheck();

                ShaderProperty("_UseScreenSpace");
                _useScreenSpace = _target.IsKeywordEnabled("_USE_SCREEN_SPACE");
                //_useScreenSpace = EditorGUILayout.Toggle(MakeLabel("Use Screen Space"), _useScreenSpace);
                if (EditorGUI.EndChangeCheck())
                {
                    RecordAction("Use Screen Space");
                    SetKeyword("_USE_SCREEN_SPACE", _useScreenSpace);

                }
                #endregion

                #region Crosshatching
                EditorGUI.BeginChangeCheck();

                ShaderProperty("_Crosshatching");
                _crosshatching = _target.IsKeywordEnabled("_CROSSHATCHING");
                //_crosshatching = EditorGUILayout.Toggle(MakeLabel("Crosshatching"), _crosshatching);
                if (EditorGUI.EndChangeCheck())
                {
                    RecordAction("Crosshatching");
                    SetKeyword("_CROSSHATCHING", _crosshatching);

                }

                #endregion

                #region Compensate Distance
                EditorGUI.BeginChangeCheck();
                ShaderProperty("_CompensateDistance");
                _compensateDistance = _target.IsKeywordEnabled("_COMPENSATE_DISTANCE");
                //_compensateDistance = EditorGUILayout.Toggle(MakeLabel("Compensate Distance"), _compensateDistance);
                if (_compensateDistance)
                {
                    EditorGUI.indentLevel += 2;
                    MaterialProperty compensationDist = FindProperty("_CompensationDistance");

                    _editor.RangeProperty(compensationDist, compensationDist.displayName);

                    MaterialProperty hatchingMinMaxSize = FindProperty("_HatchingMinimumMaximumSize");

                    EditorGUI.BeginChangeCheck();

                    EditorGUI.showMixedValue = hatchingMinMaxSize.hasMixedValue;
                    float minSize = EditorGUILayout.FloatField("Min Size", hatchingMinMaxSize.vectorValue.x);
                    if (minSize < 0) minSize = 0f;
                    float maxSize = EditorGUILayout.FloatField("Max Size", hatchingMinMaxSize.vectorValue.y);
                    if (EditorGUI.EndChangeCheck())
                    {

                        hatchingMinMaxSize.vectorValue = new Vector4(minSize, maxSize);
                    }
                    EditorGUI.indentLevel -= 2;


                }
                if (EditorGUI.EndChangeCheck())
                {

                    SetKeyword("_COMPENSATE_DISTANCE", _compensateDistance);

                }
                #endregion

                _editor.FloatProperty(FindProperty("_HatchingSize"), "Size");
                _editor.RangeProperty(FindProperty("_HatchingWidth"), "Width");
                _editor.FloatProperty(FindProperty("_HatchingRotation"), "Rotation");


            }

            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        void DrawShadows()
        {
            _shadowsFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_shadowsFoldout, "Shadows", EditorStyles.foldoutHeader);

            if (_shadowsFoldout)
            {
                _editor.ColorProperty(FindProperty("_ShadowColor"), "Shadow Color");

                _editor.FloatProperty(FindProperty("_ShadowStrength"), "Shadow Strength");


                EditorGUILayout.LabelField(MakeLabel("Shadow Transition"), EditorStyles.boldLabel);
                EditorGUI.indentLevel += 2;
                DrawVector4(FindProperty("_LightTransition"), "Minimum", "Maximum");
                EditorGUI.indentLevel -= 2;
            }

            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        void DrawHighlight()
        {
            _highligthFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_highligthFoldout, "Highlight", EditorStyles.foldoutHeader);

            if (_highligthFoldout)
            {
                EditorGUI.BeginChangeCheck();

                ShaderProperty("_UseHighlight", "Enable Highlights");

                _useHighlight = _target.IsKeywordEnabled("_USE_HIGHLIGHT");
                //_useHighlight = EditorGUILayout.Toggle(MakeLabel("Enable Highlights"), _useHighlight);

                if (_useHighlight)
                {
                    EditorGUI.indentLevel += 1;

                    EditorGUI.BeginChangeCheck();
                    ShaderProperty("_OverrideMainLightColor", "Override Main Light Color");

                    bool _overrideMainLightColor = _target.IsKeywordEnabled("_OVERRIDE_MAIN_LIGHT_COLOR");
                    //_overrideMainLightColor = EditorGUILayout.Toggle(MakeLabel("Override Main Light Color"), _overrideMainLightColor);

                    if (_overrideMainLightColor)
                    {
                        EditorGUI.indentLevel += 1;

                        _editor.ColorProperty(FindProperty("_HighlightColor"), "Highlight Color");
                        EditorGUI.indentLevel -= 1;

                    }
                    if (EditorGUI.EndChangeCheck())
                    {

                        SetKeyword("_OVERRIDE_MAIN_LIGHT_COLOR", _overrideMainLightColor);

                    }

                    RecordAction("Highlight Strength");

                    _editor.FloatProperty(FindProperty("_HighlightStrength"), "Highlight Strength");

                    EditorGUILayout.LabelField(MakeLabel("Highlight Transition"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel += 2;
                    RecordAction("Highlight Transition");

                    DrawVector4(FindProperty("_HighlightTransition"), "Minimum", "Maximum");
                    EditorGUI.indentLevel -= 2;
                    EditorGUI.indentLevel -= 1;


                }

                if (EditorGUI.EndChangeCheck())
                {

                    SetKeyword("_USE_HIGHLIGHT", _useHighlight);

                }


            }


            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        void DrawFresnel()
        {
            _fresnelFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_fresnelFoldout, "Fresnel", EditorStyles.foldoutHeader);

            if (_fresnelFoldout)
            {
                EditorGUI.BeginChangeCheck();
                ShaderProperty("_UseFresnel");
                _useFresnel = _target.IsKeywordEnabled("_USE_FRESNEL");
                RecordAction("Enable Fresnel");

                //_useFresnel = EditorGUILayout.Toggle(MakeLabel("Enable Fresnel"), _useFresnel);

                if (_useFresnel)
                {
                    EditorGUI.indentLevel += 1;

                    EditorGUI.BeginChangeCheck();

                    ShaderProperty("_RealisticFresnel");
                    _realisticFresnel = _target.IsKeywordEnabled("_REALISTIC_FRESNEL");
                    RecordAction("Enable Realistic Fresnel");

                    //_realisticFresnel = EditorGUILayout.Toggle(MakeLabel("Realistic Fresnel"), _realisticFresnel);
                    if (EditorGUI.EndChangeCheck())
                    {

                        SetKeyword("_REALISTIC_FRESNEL", _realisticFresnel);

                    }

                    RecordAction("Fresnel Color");

                    _editor.ColorProperty(FindProperty("_FresnelColor"), "Fresnel Color");
                    RecordAction("Fresnel Scale");

                    _editor.FloatProperty(FindProperty("_FresnelScale"), "Fresnel Scale");
                    RecordAction("Fresnel Power");

                    _editor.FloatProperty(FindProperty("_FresnelPower"), "Fresnel Power");

                    EditorGUI.indentLevel -= 1;


                }

                if (EditorGUI.EndChangeCheck())
                {

                    SetKeyword("_USE_FRESNEL", _useFresnel);

                }


            }


            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        void DrawAdditionalLights()
        {

            _addLightsFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_addLightsFoldout, "Additional Lights", EditorStyles.foldoutHeader);

            if (_addLightsFoldout)
            {
                bool _useAddLights;
                EditorGUI.BeginChangeCheck();
                ShaderProperty("_UseAdditionalLights", "Enable Additional Lights");
                _useAddLights = _target.IsKeywordEnabled("_USE_ADDITIONAL_LIGHTS");

                RecordAction("Enable Additional Lights Color");

                //_useAddLights = EditorGUILayout.Toggle(MakeLabel("Enable Additional Lights"), _useAddLights);

                if (_useAddLights)
                {
                    EditorGUI.indentLevel += 1;

                    bool _overrideAddLightsColor;
                    EditorGUI.BeginChangeCheck();

                    ShaderProperty("_OverrideAdditionalLightsColor", "Override Color");

                    _overrideAddLightsColor = _target.IsKeywordEnabled("_OVERRIDE_ADD_LIGHTS_COLOR");
                    RecordAction("Override Additional Lights Color");

                    //_overrideAddLightsColor = EditorGUILayout.Toggle(MakeLabel("Override Color"), _overrideAddLightsColor);
                    if (_overrideAddLightsColor)
                    {
                        EditorGUI.indentLevel += 1;

                        RecordAction("Additional Lights Color");

                        _editor.ColorProperty(FindProperty("_AddLightsColor"), "Additional Lights Color");
                        EditorGUI.indentLevel -= 1;

                    }


                    if (EditorGUI.EndChangeCheck())
                    {

                        SetKeyword("_OVERRIDE_ADD_LIGHTS_COLOR", _overrideAddLightsColor);

                    }
                    EditorGUI.indentLevel -= 1;


                }

                if (EditorGUI.EndChangeCheck())
                {

                    SetKeyword("_USE_ADDITIONAL_LIGHTS", _useAddLights);

                }

            }

            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        void DrawOutline()
        {
            _outlineFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_outlineFoldout, "Outline", EditorStyles.foldoutHeader);

            if (_outlineFoldout)
            {
                EditorGUI.BeginChangeCheck();

                ShaderProperty("_UseOutline", "Enable Outline");
                _useOutline = _target.IsKeywordEnabled("_USE_OUTLINE");
                RecordAction("Enable Outline");
                //_useOutline = EditorGUILayout.Toggle(MakeLabel("Enable Outline"), _useOutline);

                if (_useOutline)
                {
                    EditorGUI.indentLevel += 1;



                    RecordAction("Outline Size");
                    _editor.FloatProperty(FindProperty("_OutlineSize"), "Outline Size");
                    RecordAction("Outline Color");

                    _editor.ColorProperty(FindProperty("_OutlineColor"), "Outline Color");

                    EditorGUI.indentLevel -= 1;


                }

                if (EditorGUI.EndChangeCheck())
                {

                    SetKeyword("_USE_OUTLINE", _useOutline);

                }


            }


            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        MaterialProperty FindProperty(string name)
        {

            return FindProperty(name, _properties);


        }

        void ShaderProperty(string name, string label = null)
        {
            var property = FindProperty(name);
            _editor.ShaderProperty(property, label == null ? property.displayName : label);

        }

        void SetKeyword(string keyword, bool enabled)
        {
            if (enabled)
            {
                _target.EnableKeyword(keyword);
                //_target.SetKeyword(in )
            }
            else
            {
                _target.DisableKeyword(keyword);
            }
        }
        static GUIContent staticLabel = new GUIContent();

        static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
        {
            staticLabel.text = property.displayName;
            staticLabel.tooltip = tooltip;
            return staticLabel;
        }
        static GUIContent MakeLabel(string name, string tooltip = null)
        {
            staticLabel.text = name;
            staticLabel.tooltip = tooltip;
            return staticLabel;

        }
        static void DrawVector4(MaterialProperty property, string Xname, string Yname)
        {
            EditorGUI.BeginChangeCheck();

            EditorGUI.showMixedValue = property.hasMixedValue;
            float Xvalue = EditorGUILayout.FloatField(Xname, property.vectorValue.x);

            float Yvalue = EditorGUILayout.FloatField(Yname, property.vectorValue.y);
            if (EditorGUI.EndChangeCheck())
            {
                property.vectorValue = new Vector4(Xvalue, Yvalue);
            }

        }

        void RecordAction(string actionName)
        {
            _editor.RegisterPropertyChangeUndo(actionName);
        }

        public static class BackgroundStyle
        {
            private static GUIStyle style = new GUIStyle();
            private static Texture2D texture = new Texture2D(1, 1);


            public static GUIStyle Get(Color color)
            {
                texture.SetPixel(0, 0, color);
                texture.Apply();
                style.normal.background = texture;
                return style;
            }

            public static Texture2D GetTexture(Color color)
            {
                texture.SetPixel(0, 0, color);
                texture.Apply();
                return texture;
            }
        }

        struct RenderingSettings
        {
            public RenderQueue queue;
            public string renderType;

            public static RenderingSettings[] modes = {
            new RenderingSettings() {
                queue = RenderQueue.Geometry,
                renderType = ""
            },
            new RenderingSettings() {
                queue = RenderQueue.AlphaTest,
                renderType = "TransparentCutout"
            },
            new RenderingSettings() {
                queue = RenderQueue.Transparent,
                renderType = "Transparent"
            }
        };
        }
    }


}