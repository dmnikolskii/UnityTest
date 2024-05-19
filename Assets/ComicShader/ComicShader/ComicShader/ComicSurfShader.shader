Shader "Comic Surf Shader"
// Try fragment shader for point lights later..
{
	Properties
	{
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)

		_Emission ("Emission", 2D) = "white" {}
		[HDR]_EmissionHDR ("EmissionHDR", color) = (0,0,0,0)

		_Normal ("Normal Map", 2D) = "bump" {}
		_NormalStrength ("Normal Strength", Range (0,2)) = 1
		
		[NoScaleOffset]_WShadow("Shadow Weight", 2D) = "gray" {}
		[NoScaleOffset]_ShaMask ("Shadow Mask", 2D) = "black" {}
		_ShadowMultiplier ("Intensity", Range(0, 2)) = 1
		_ShadowWBlack ("Black", Range (0,1)) = 0
		_ShadowWWhite ("White", Range (0,1)) = 0.15
		_ShadowWContrast ("Weight Contrast", Range (0,1)) = 1
		_ShaTex1 ("Shadow Texture 1", 2D) = "" {}
		[NoScaleOffset]_ShaTex2 ("Shadow Texture 2", 2D) = "" {}


		[HideInInspector]_Alpha ("Alpha", Range (0,1)) = 1
		_Specular("Specular", Color) = (0,0,0,0)
		[NoScaleOffset]_Smoothness ("Smoothness", 2D) = "white" {}
		_SmoothnessMulti ("Smoothness Multiplayer", Range (0,1)) = 0


		[NoScaleOffset]_SkinMask ("Skin Mask", 2D) = "white" {}	
		_SkinColor ("Skin Color", Color) = (1,1,1,1)
		_SkinColorVal ("Skin Color Value", Range (0,1)) = 0
		_ClothColor ("Cloth Color", Color) = (1,1,1,1)
		_ClothColorVal ("Cloth Color Value", Range (0,1)) = 0

		_SkinShadowHue ("Skin Shadow Hue", Range (0,1)) = 1
		_SkinShadowBrightness ("Skin Shadow Brightness", Range (0,1)) = 0
		_SkinShadowContrast ("Skin Shadow Contrast", Range (0,1)) = 0
		_SkinShadowSaturation ("Skin Shadow Saturation", Range (0,1)) = 1

		_ClothShadowHue ("Cloth Shadow Hue", Range (0,1)) = 1
		_ClothShadowBrightness ("Cloth Shadow Brightness", Range (0,1)) = 0
		_ClothShadowContrast ("Cloth Shadow Contrast", Range (0,1)) = 0
		_ClothShadowSaturation ("Cloth Shadow Saturation", Range (0,1)) = 1

	}

	SubShader
	{
		Tags {"RenderType" = "Opaque"}

		CGPROGRAM
		#pragma surface surf NPRSpecular fullforwardshadows
		#pragma shader_feature STYLISTIC_ON STYLISTIC_OFF
		#pragma shader_feature NORMAL_ON NORMAL_OFF
		#pragma target 3.0

		#include "UnityPBSLighting.cginc"

		struct SurfaceOutputNPRSpecular
		{
			fixed3 Albedo;      // diffuse color
			fixed3 Specular;    // specular color
			float3 Normal;      // tangent space normal, if written
			half3 Emission;
			half Smoothness;    // 0=rough, 1=smooth
			fixed Alpha;        // alpha for transparencies

			fixed ShadowWeight;
			fixed3 shadowTexture1;
			fixed3 shadowTexture2;
			fixed3 shadowTexture1Rot;
			fixed3 shadowTexture2Rot;

			fixed skinMask;
			fixed4 clothCrossColor;
			fixed4 skinCrossColor;
		};

		inline void LightingNPRSpecular_GI (SurfaceOutputNPRSpecular s, UnityGIInput data, inout UnityGI gi)
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, 1, s.Normal);
			#else
				Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, s.Specular);
				gi = UnityGlobalIllumination(data, 1, s.Normal, g);
			#endif
		}

		inline half shadowParse(fixed3 shadowTex1, fixed3 shadowTex2, half4 lightVal)
		{
			fixed3 shadowCombined;
			shadowCombined = lerp (shadowTex1.r, 0, clamp(((lightVal- 0.875)* 20), 0, 1));
			shadowCombined = lerp (shadowTex1.g, shadowCombined, clamp(((lightVal- 0.750)*20), 0, 1));
			shadowCombined = lerp (shadowTex1.b, shadowCombined, clamp(((lightVal- 0.625)*20), 0, 1));
			shadowCombined = lerp (shadowTex2.r, shadowCombined, clamp(((lightVal- 0.500)*20), 0, 1));
			shadowCombined = lerp (shadowTex2.g, shadowCombined, clamp(((lightVal- 0.375)*20), 0, 1));
			shadowCombined = lerp (shadowTex2.b, shadowCombined, clamp(((lightVal- 0.250)*20), 0, 1));
			shadowCombined = lerp (1, shadowCombined, clamp(((lightVal- 0.125)*20), 0, 1));
			return shadowCombined;
		}

		inline half lightParse(fixed3 shadowTex1, fixed3 shadowTex2, half3 lightVal)
		{
			fixed3 lightCombined;

			lightCombined = lerp (shadowTex2.b, 1, clamp(((lightVal- 0.875)* 20), 0, 1));
			lightCombined = lerp (shadowTex2.g, lightCombined, clamp(((lightVal- 0.750)*20), 0, 1));
			lightCombined = lerp (shadowTex2.r, lightCombined, clamp(((lightVal- 0.625)*20), 0, 1));
			lightCombined = lerp (shadowTex1.b, lightCombined, clamp(((lightVal- 0.500)*20), 0, 1));
			lightCombined = lerp (shadowTex1.g, lightCombined, clamp(((lightVal- 0.375)*20), 0, 1));
			lightCombined = lerp (shadowTex1.r, lightCombined, clamp(((lightVal- 0.250)*20), 0, 1));
			lightCombined = lerp (0, lightCombined, clamp(((lightVal- 0.125)*20), 0, 1));

			return lightCombined;
		}

		inline float3 colorBurn (float3 startCol, float3 mulColor)
		{
			float3 burned;

			burned = 1-(1-startCol)/mulColor;

			return burned;
		}

		inline fixed3 softLight (fixed3 startColor, fixed3 softLightCol, fixed val)
		{
			fixed3 finalColor = (1-2*softLightCol)*pow(startColor,2) + 2*softLightCol*startColor;
			
			return lerp(startColor, finalColor, val);

		}

		inline float3 applyHue(float3 aColor, float aHue)
		{
			float angle = radians(aHue);
			float3 k = float3(0.57735, 0.57735, 0.57735);
			float cosAngle = cos(angle);
			//Rodrigues' rotation formula
			return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
		}
		
		
		inline fixed3 applyHSBEffect(fixed3 startColor, fixed4 hsbc)
		{
			fixed _Hue = 360 * hsbc.r;
			fixed _Brightness = hsbc.g * 2 - 1;
			fixed _Contrast = hsbc.b * 2;
			fixed _Saturation = hsbc.a * 2;
		
			fixed3 outputColor = startColor;
			outputColor.rgb = applyHue(outputColor.rgb, _Hue);
			outputColor.rgb = (outputColor.rgb - 0.5f) * (_Contrast) + 0.5f;
			outputColor.rgb = outputColor.rgb + _Brightness;      
			fixed3 intensity = dot(outputColor.rgb, fixed3(0.299,0.587,0.114));
			outputColor.rgb = lerp(intensity, outputColor.rgb, _Saturation);
		
			return outputColor;
		}

		sampler2D _HatchTex1;
		sampler2D _HatchTex2;
		float2 uv_HatchTex1;
		float4 _HatchTex2_ST;
		fixed _ShadowMultiplier;
		
		half4 LightingNPRSpecular (SurfaceOutputNPRSpecular s, float3 viewDir, UnityGI gi)
		{
			s.Normal = normalize(s.Normal);

			fixed3 clothCross;
			fixed3 skinCross;

			// energy conservation
			half oneMinusReflectivity;
			fixed3 albedoOrigin = s.Albedo;
			s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);
			
			// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
			// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
			half outputAlpha;
			s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
			half4 c = UNITY_BRDF_PBS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect); 

			// Lighted model black and white values.
			half grayVal = (c.r + c.g + c.b)/2 *s.ShadowWeight;
			half specVal = (s.Specular.r + s.Specular.g + s.Specular.b) / 3;

			half3 specular = max(grayVal,0)*specVal;

			half4 specularLayer = half4 (s.Specular*s.Specular * lightParse(s.shadowTexture1Rot, s.shadowTexture2Rot, specular),1);

			#if STYLISTIC_ON


			if (0.0 == _WorldSpaceLightPos0.w)
			{
			//white shadows
			c = shadowParse(s.shadowTexture1, s.shadowTexture2,  clamp ((grayVal / _ShadowMultiplier),0.2,2));
			//colored shadows
			s.clothCrossColor.g = lerp (0, s.clothCrossColor.g ,_LightColor0.rgb);
			s.skinCrossColor.g = lerp (0, s.skinCrossColor.g ,_LightColor0.rgb);
			clothCross = c*(1-s.skinMask)*applyHSBEffect((albedoOrigin * _LightColor0.rgb) ,s.clothCrossColor);
			skinCross = c*(s.skinMask)*applyHSBEffect((albedoOrigin * _LightColor0.rgb) ,s.skinCrossColor);


			c.rgb = albedoOrigin* (_LightColor0.rgb +gi.indirect.diffuse/2) + skinCross + clothCross;
			}
			else
			{
				c.rgb = lightParse(s.shadowTexture1Rot, s.shadowTexture2Rot,  grayVal / _ShadowMultiplier);
				clothCross = c*(1-s.skinMask)*applyHSBEffect((albedoOrigin * _LightColor0.rgb) ,s.clothCrossColor);
				skinCross = c*(s.skinMask)*applyHSBEffect((albedoOrigin * _LightColor0.rgb) ,s.skinCrossColor);

				c.rgb = skinCross + clothCross;
			}

			c.rgb = softLight(c.rgb + specularLayer, s.Emission,1);

			c.a = outputAlpha;
			
			return c;


			#endif //STYLISTIC_ON

			#if STYLISTIC_OFF

			if (0.0 == _WorldSpaceLightPos0.w)
			c = half4 (albedoOrigin * (_LightColor0.rgb +gi.indirect.diffuse/2) * (1 - shadowParse(s.shadowTexture1, s.shadowTexture2,  clamp ((grayVal / _ShadowMultiplier),0.2,2) )),1);
			else
			c.rgb = albedoOrigin * _LightColor0.rgb  * (lightParse(s.shadowTexture1Rot, s.shadowTexture2Rot,  grayVal / _ShadowMultiplier));

			c.rgb = c.rgb + specularLayer;

			c.a = outputAlpha;
			
			return c;

			#endif //STYLISTIC_OFF
		}

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_ShaTex1;
		};

		fixed3 _Color;
		fixed3 _SkinColor;
		fixed3 _ClothColor;
		fixed _Alpha;
		fixed3 _Specular;
		sampler2D _Smoothness;
		half _NormalStrength;

		sampler2D _MainTex;
		sampler2D _Emission;
		sampler2D _Normal;
		sampler2D _ShaTex1;
		sampler2D _ShaTex2;
		sampler2D _ShaMask;
		sampler2D _SkinMask;

		sampler2D _WShadow;
		fixed _ShadowWBlack;
		fixed _ShadowWWhite;
		fixed _ShadowWContrast;
		fixed _SkinColorVal;
		fixed _ClothColorVal;
		fixed _SmoothnessMulti;
		fixed3 _EmissionHDR;

		fixed _ClothShadowHue;
		fixed _ClothShadowBrightness;
		fixed _ClothShadowContrast;
		fixed _ClothShadowSaturation;

		fixed _SkinShadowHue;
		fixed _SkinShadowBrightness;
		fixed _SkinShadowContrast;
		fixed _SkinShadowSaturation;

		void surf (Input IN, inout SurfaceOutputNPRSpecular o)
		{
			o.Smoothness = tex2D (_Smoothness, IN.uv_MainTex).r * _SmoothnessMulti;
			o.Emission = tex2D (_Emission, IN.uv_MainTex).rgb * _EmissionHDR;

			#if NORMAL_ON

			o.Normal = UnpackNormal ( tex2D (_Normal, IN.uv_MainTex));

			o.Normal.rg = o.Normal.rg *_NormalStrength;

			#endif

			o.Specular = _Specular;

			o.Alpha = _Alpha;

			float2x2 rotationMatrix = float2x2(0, -1, 1, 0);
        	float2 uv_ShaTex2 = mul (IN.uv_ShaTex1.xy, rotationMatrix );

			fixed shamask = tex2D (_ShaMask, IN.uv_MainTex).r + step (0.01, o.Emission.r + o.Emission.g + o.Emission.b);

			o.shadowTexture1 = clamp (tex2D (_ShaTex1, IN.uv_ShaTex1).rgb * (1-shamask),0,1);
			o.shadowTexture2 = clamp (tex2D (_ShaTex2, IN.uv_ShaTex1).rgb * (1-shamask),0,1);
			o.shadowTexture1Rot = clamp (tex2D (_ShaTex1, uv_ShaTex2).rgb * (1-shamask),0,1);
			o.shadowTexture2Rot = clamp (tex2D (_ShaTex2, uv_ShaTex2).rgb * (1-shamask),0,1);

			fixed shadowSample = tex2D (_WShadow, IN.uv_MainTex).r;

			shadowSample = clamp(shadowSample, _ShadowWBlack, _ShadowWWhite);

			shadowSample =  (shadowSample - 0.5) * _ShadowWContrast + 0.5;

			o.ShadowWeight = shadowSample;

			#if STYLISTIC_OFF
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color;
			#endif //STYLISTIC_OFF

			#if STYLISTIC_ON
			o.skinCrossColor = fixed4 (_SkinShadowHue, _SkinShadowBrightness, _SkinShadowContrast, _SkinShadowSaturation);
			o.clothCrossColor = fixed4 (_ClothShadowHue, _ClothShadowBrightness, _ClothShadowContrast, _ClothShadowSaturation);

			o.skinMask = tex2D (_SkinMask, IN.uv_MainTex).r;

			fixed3 skinColor = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color * o.skinMask;
			fixed3 clothColor = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color * (1-o.skinMask);			

			o.Albedo = softLight(clothColor, _ClothColor, _ClothColorVal) + softLight(skinColor, _SkinColor, _SkinColorVal);

			#endif // STYLISTIC_ON
		}		
		ENDCG
	}

	CustomEditor "ComicUnityGUI"
	FallBack "Diffuse"
}