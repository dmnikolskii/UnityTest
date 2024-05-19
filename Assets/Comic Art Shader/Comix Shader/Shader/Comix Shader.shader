// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Eugeen/ComixShader"
{
	Properties
	{
		[Enum (UnityEngine.Rendering.CullMode)]_Cull ("Culling", Float) = 2.0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_NormalStrength("Normal Strength", Float) = 1
		_Tint("Tint", Color) = (1,1,1,0)
		[Toggle(_USE_SCREEN_SPACE)] _UseScreenSpace("Use Screen Space", Float) = 1
		[Toggle(_COMPENSATE_DISTANCE)] _CompensateDistance("Compensate Distance", Float) = 0
		_CompensationDistance("Compensation Distance", Range( 0.1 , 2)) = 0
		[ShowAsVector2]_HatchingMinimumMaximumSize("Hatching Minimum Maximum Size", Vector) = (0,0,0,0)
		_HatchingSize("Hatching Size", Float) = 30
		_HatchingWidth("Hatching Width", Range( 0.5 , 10)) = 3
		_HatchingRotation("Hatching Rotation", Float) = 1
		[Toggle(_CROSSHATCHING)] _Crosshatching("Crosshatching", Float) = 0
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_ShadowStrength("Shadow Strength", Float) = 1
		_LightTransition("Light Transition", Vector) = (0.45,0.67,0,0)
		[Toggle(_USE_HIGHLIGHT)] _UseHighlight("Use Highlight", Float) = 0
		_HighlightColor("Highlight Color", Color) = (1,1,1,0)
		_HighlightStrength("Highlight Strength", Float) = 1
		_HighlightTransition("Highlight Transition", Vector) = (0.8,0.9,0,0)
		[Toggle(_USE_FRESNEL)] _UseFresnel("Use Fresnel", Float) = 0
		[Toggle(_REALISTIC_FRESNEL)] _RealisticFresnel("Realistic Fresnel", Float) = 1
		_FresnelColor("Fresnel Color", Color) = (0.627937,0.9716981,0.9359638,1)
		_FresnelScale("Fresnel Scale", Float) = 1
		_FresnelPower("Fresnel Power", Float) = 1
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		_Cull("Cull", Float) = 2
		[Toggle(_USE_ADDITIONAL_LIGHTS)] _UseAdditionalLights("Use Additional Lights", Float) = 0
		[Toggle(_OVERRIDE_MAIN_LIGHT_COLOR)] _OverrideMainLightColor("Override Main Light Color", Float) = 0
		_AddLightsColor("AddLightsColor", Color) = (0,0,0,0)
		[Toggle(_OVERRIDE_ADD_LIGHTS_COLOR)] _OverrideAdditionalLightsColor("Override Additional Lights Color", Float) = 1
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_LineArtMask("_LineArtMask", 2D) = "black" {}
		_LineArtStrength("Line Art Strength", Float) = 2
		_LineArtShadowColor("Line Art Shadow Color", Color) = (0.2904586,0.03631186,0.4528302,1)
		_LineArtMainColor("Line Art Main Color", Color) = (1,1,1,1)
		[Toggle(_USE_LINEART)] _UseLineArt("Use Line Art", Float) = 1
		[Toggle(_USE_PROC_LINEART)] _UseProceduralLineArt("Use Procedural Line Art", Float) = 1
		_LineArtSmoothstepValues("Line Art Smoothstep Values", Vector) = (0,1,0,0)
		[Toggle(_INVERT_LINE_SHADOW_COLOR)] _InvertLineArtShadowColor("Invert Line Art Shadow Color ", Float) = 0
		[ASEEnd][Toggle(_OVERRIDE_LINEART_SHADOW)] _OverrideLineArtShadowColor("Override Line Art Shadow Color", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		//Cull [_Cull]
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull [_Cull]
		AlphaToMask On

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			Name "ExtraPrePass"
			

			Blend One Zero
			Cull Front
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _LineArtMainColor;
			half4 _MainTex_ST;
			half4 _Tint;
			half4 _ShadowColor;
			half4 _FresnelColor;
			half4 _LineArtShadowColor;
			half4 _HighlightColor;
			half4 _AddLightsColor;
			half4 _NormalMap_ST;
			half4 _LineArtMask_ST;
			half2 _LineArtSmoothstepValues;
			half2 _HatchingMinimumMaximumSize;
			half2 _LightTransition;
			half2 _HighlightTransition;
			half _Cull;
			half _LineArtStrength;
			half _FresnelPower;
			half _NormalStrength;
			half _HighlightStrength;
			half _ShadowStrength;
			half _HatchingWidth;
			half _HatchingRotation;
			half _CompensationDistance;
			half _HatchingSize;
			half _FresnelScale;
			half _AlphaCutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float3 Color = float3( 0, 0, 0 );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
        	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
        	#pragma shader_feature _ _SAMPLE_GI
        	#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#pragma shader_feature_local _USE_LINEART
			#pragma shader_feature_local _USE_ADDITIONAL_LIGHTS
			#pragma shader_feature_local _USE_FRESNEL
			#pragma shader_feature_local _USE_HIGHLIGHT
			#pragma shader_feature_local _CROSSHATCHING
			#pragma shader_feature_local _USE_SCREEN_SPACE
			#pragma shader_feature_local _COMPENSATE_DISTANCE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma shader_feature_local _OVERRIDE_MAIN_LIGHT_COLOR
			#pragma shader_feature_local _REALISTIC_FRESNEL
			#pragma shader_feature_local _OVERRIDE_ADD_LIGHTS_COLOR
			#pragma shader_feature_local _OVERRIDE_LINEART_SHADOW
			#pragma shader_feature_local _INVERT_LINE_SHADOW_COLOR
			#pragma shader_feature_local _USE_PROC_LINEART


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _LineArtMainColor;
			half4 _MainTex_ST;
			half4 _Tint;
			half4 _ShadowColor;
			half4 _FresnelColor;
			half4 _LineArtShadowColor;
			half4 _HighlightColor;
			half4 _AddLightsColor;
			half4 _NormalMap_ST;
			half4 _LineArtMask_ST;
			half2 _LineArtSmoothstepValues;
			half2 _HatchingMinimumMaximumSize;
			half2 _LightTransition;
			half2 _HighlightTransition;
			half _Cull;
			half _LineArtStrength;
			half _FresnelPower;
			half _NormalStrength;
			half _HighlightStrength;
			half _ShadowStrength;
			half _HatchingWidth;
			half _HatchingRotation;
			half _CompensationDistance;
			half _HatchingSize;
			half _FresnelScale;
			half _AlphaCutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_LineArtMask);
			SAMPLER(sampler_LineArtMask);


			half3 AdditionalLightsHalfLambert14x( float3 WorldPosition, half2 ScreenUV, float3 WorldNormal )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
				#define SUM_LIGHT(Light)\
					half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
					Color += ( dot( Light.direction, WorldNormal ) * 0.5 + 0.5 )* AttLightColor;
				uint meshRenderingLayers = GetMeshRenderingLayer();
				uint pixelLightCount = GetAdditionalLightsCount();	
				#if USE_FORWARD_PLUS
				for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
				{
					Light light = GetAdditionalLight(lightIndex, WorldPosition);
					#ifdef _LIGHT_LAYERS
					if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
					#endif
					{
						SUM_LIGHT( light );
					}
				}
				ClusteredLightLoop cll = ClusteredLightLoopInit( ScreenUV, WorldPosition );
				[loop] while ( ClusteredLightLoopNext( cll ) ) {
				uint lightIndex = ClusteredLightLoopGetLightIndex( cll );
				#else
				for( uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++ ) {
				#endif
					Light light = GetAdditionalLight(lightIndex, WorldPosition);
					#ifdef _LIGHT_LAYERS
					if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
					#endif
					{
						SUM_LIGHT( light );
					}
				}
				#endif
				return Color;
			}
			
			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord3.z = eyeDepth;
				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 temp_output_160_0 = ( SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex ) * _Tint );
				#ifdef _USE_SCREEN_SPACE
				half staticSwitch101 = (float)1;
				#else
				half staticSwitch101 = (float)0;
				#endif
				half UseScreenSpace193 = staticSwitch101;
				half4 unityObjectToClipPos3_g167 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord4.xyz));
				half4 computeScreenPos5_g167 = ComputeScreenPos( unityObjectToClipPos3_g167 );
				float eyeDepth = IN.ase_texcoord3.z;
				half cameraDepthFade242 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / _CompensationDistance);
				half clampResult246 = clamp( ( _HatchingSize / cameraDepthFade242 ) , _HatchingMinimumMaximumSize.x , _HatchingMinimumMaximumSize.y );
				#ifdef _COMPENSATE_DISTANCE
				half staticSwitch247 = clampResult246;
				#else
				half staticSwitch247 = _HatchingSize;
				#endif
				half HatchingSize201 = staticSwitch247;
				half temp_output_29_0_g165 = HatchingSize201;
				half temp_output_20_0_g167 = temp_output_29_0_g165;
				half4 unityObjectToClipPos4_g167 = TransformWorldToHClip(TransformObjectToWorld(float3(0,0,0)));
				half4 computeScreenPos6_g167 = ComputeScreenPos( unityObjectToClipPos4_g167 );
				half4 transform10_g167 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				half2 temp_output_34_0_g165 = ( (int)UseScreenSpace193 == 1 ? (( ( ( ( computeScreenPos5_g167 / (computeScreenPos5_g167).w ) * temp_output_20_0_g167 ) - ( temp_output_20_0_g167 * ( computeScreenPos6_g167 / (computeScreenPos6_g167).w ) ) ) * length( ( half4( _WorldSpaceCameraPos , 0.0 ) - transform10_g167 ) ) )).xy : ( temp_output_29_0_g165 * IN.ase_texcoord3.xy ) );
				half HatchingRotation200 = _HatchingRotation;
				float cos15_g165 = cos( HatchingRotation200 );
				float sin15_g165 = sin( HatchingRotation200 );
				half2 rotator15_g165 = mul( temp_output_34_0_g165 - float2( 0,0 ) , float2x2( cos15_g165 , -sin15_g165 , sin15_g165 , cos15_g165 )) + float2( 0,0 );
				half2 break4_g165 = rotator15_g165;
				half2 break31_g165 = float2( 0.5,0 );
				half2 appendResult12_g165 = (half2(( break4_g165.x + ( break31_g165.x * step( 1.0 , ( break4_g165.y % 2.0 ) ) ) ) , ( break4_g165.y + ( break31_g165.y * step( 1.0 , ( break4_g165.x % 2.0 ) ) ) )));
				half HatchingWidth199 = _HatchingWidth;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float2 uv_NormalMap = IN.ase_texcoord3.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half3 unpack532 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ), _NormalStrength );
				unpack532.z = lerp( 1, unpack532.z, saturate(_NormalStrength) );
				half3 tex2DNode532 = unpack532;
				half3 ase_worldTangent = IN.ase_texcoord5.xyz;
				half3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal77 = tex2DNode532;
				half3 worldNormal77 = float3(dot(tanToWorld0,tanNormal77), dot(tanToWorld1,tanNormal77), dot(tanToWorld2,tanNormal77));
				half3 WorldNormal342 = worldNormal77;
				half dotResult12 = dot( _MainLightPosition.xyz , WorldNormal342 );
				half temp_output_14_0 = ( ase_lightAtten * dotResult12 );
				half smoothstepResult97 = smoothstep( _LightTransition.x , _LightTransition.y , temp_output_14_0);
				half Light325 = ( _ShadowStrength * ( 1.0 - smoothstepResult97 ) );
				half2 appendResult11_g166 = (half2(HatchingWidth199 , Light325));
				half temp_output_17_0_g166 = length( ( (frac( appendResult12_g165 )*2.0 + -1.0) / appendResult11_g166 ) );
				half temp_output_729_0 = saturate( ( ( 1.0 - temp_output_17_0_g166 ) / fwidth( temp_output_17_0_g166 ) ) );
				half4 unityObjectToClipPos3_g155 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord4.xyz));
				half4 computeScreenPos5_g155 = ComputeScreenPos( unityObjectToClipPos3_g155 );
				half temp_output_29_0_g153 = HatchingSize201;
				half temp_output_20_0_g155 = temp_output_29_0_g153;
				half4 unityObjectToClipPos4_g155 = TransformWorldToHClip(TransformObjectToWorld(float3(0,0,0)));
				half4 computeScreenPos6_g155 = ComputeScreenPos( unityObjectToClipPos4_g155 );
				half4 transform10_g155 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				half2 temp_output_34_0_g153 = ( (int)UseScreenSpace193 == 1 ? (( ( ( ( computeScreenPos5_g155 / (computeScreenPos5_g155).w ) * temp_output_20_0_g155 ) - ( temp_output_20_0_g155 * ( computeScreenPos6_g155 / (computeScreenPos6_g155).w ) ) ) * length( ( half4( _WorldSpaceCameraPos , 0.0 ) - transform10_g155 ) ) )).xy : ( temp_output_29_0_g153 * IN.ase_texcoord3.xy ) );
				float cos15_g153 = cos( ( 1.0 - HatchingRotation200 ) );
				float sin15_g153 = sin( ( 1.0 - HatchingRotation200 ) );
				half2 rotator15_g153 = mul( temp_output_34_0_g153 - float2( 0,0 ) , float2x2( cos15_g153 , -sin15_g153 , sin15_g153 , cos15_g153 )) + float2( 0,0 );
				half2 break4_g153 = rotator15_g153;
				half2 break31_g153 = float2( 0.5,0 );
				half2 appendResult12_g153 = (half2(( break4_g153.x + ( break31_g153.x * step( 1.0 , ( break4_g153.y % 2.0 ) ) ) ) , ( break4_g153.y + ( break31_g153.y * step( 1.0 , ( break4_g153.x % 2.0 ) ) ) )));
				half2 appendResult11_g154 = (half2(HatchingWidth199 , Light325));
				half temp_output_17_0_g154 = length( ( (frac( appendResult12_g153 )*2.0 + -1.0) / appendResult11_g154 ) );
				#ifdef _CROSSHATCHING
				half staticSwitch166 = ( temp_output_729_0 + saturate( ( ( 1.0 - temp_output_17_0_g154 ) / fwidth( temp_output_17_0_g154 ) ) ) );
				#else
				half staticSwitch166 = temp_output_729_0;
				#endif
				half Shading87 = saturate( staticSwitch166 );
				half4 lerpResult156 = lerp( temp_output_160_0 , _ShadowColor , ( _ShadowColor.a * Shading87 ));
				half4 unityObjectToClipPos3_g158 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord4.xyz));
				half4 computeScreenPos5_g158 = ComputeScreenPos( unityObjectToClipPos3_g158 );
				half temp_output_29_0_g156 = HatchingSize201;
				half temp_output_20_0_g158 = temp_output_29_0_g156;
				half4 unityObjectToClipPos4_g158 = TransformWorldToHClip(TransformObjectToWorld(float3(0,0,0)));
				half4 computeScreenPos6_g158 = ComputeScreenPos( unityObjectToClipPos4_g158 );
				half4 transform10_g158 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				half2 temp_output_34_0_g156 = ( (int)UseScreenSpace193 == 1 ? (( ( ( ( computeScreenPos5_g158 / (computeScreenPos5_g158).w ) * temp_output_20_0_g158 ) - ( temp_output_20_0_g158 * ( computeScreenPos6_g158 / (computeScreenPos6_g158).w ) ) ) * length( ( half4( _WorldSpaceCameraPos , 0.0 ) - transform10_g158 ) ) )).xy : ( temp_output_29_0_g156 * IN.ase_texcoord3.xy ) );
				float cos15_g156 = cos( HatchingRotation200 );
				float sin15_g156 = sin( HatchingRotation200 );
				half2 rotator15_g156 = mul( temp_output_34_0_g156 - float2( 0,0 ) , float2x2( cos15_g156 , -sin15_g156 , sin15_g156 , cos15_g156 )) + float2( 0,0 );
				half2 break4_g156 = rotator15_g156;
				half2 break31_g156 = float2( 0.5,0 );
				half2 appendResult12_g156 = (half2(( break4_g156.x + ( break31_g156.x * step( 1.0 , ( break4_g156.y % 2.0 ) ) ) ) , ( break4_g156.y + ( break31_g156.y * step( 1.0 , ( break4_g156.x % 2.0 ) ) ) )));
				half smoothstepResult171 = smoothstep( _HighlightTransition.x , _HighlightTransition.y , temp_output_14_0);
				half2 appendResult11_g157 = (half2(HatchingWidth199 , ( pow( smoothstepResult171 , 10.0 ) * _HighlightStrength )));
				half temp_output_17_0_g157 = length( ( (frac( appendResult12_g156 )*2.0 + -1.0) / appendResult11_g157 ) );
				half temp_output_726_0 = saturate( ( ( 1.0 - temp_output_17_0_g157 ) / fwidth( temp_output_17_0_g157 ) ) );
				#ifdef _OVERRIDE_MAIN_LIGHT_COLOR
				half4 staticSwitch329 = ( _HighlightColor * temp_output_726_0 * _HighlightColor.a );
				#else
				half4 staticSwitch329 = saturate( ( temp_output_726_0 * _MainLightColor * _MainLightColor.a ) );
				#endif
				half4 lerpResult191 = lerp( lerpResult156 , staticSwitch329 , staticSwitch329);
				#ifdef _USE_HIGHLIGHT
				half4 staticSwitch250 = lerpResult191;
				#else
				half4 staticSwitch250 = lerpResult156;
				#endif
				half4 unityObjectToClipPos3_g164 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord4.xyz));
				half4 computeScreenPos5_g164 = ComputeScreenPos( unityObjectToClipPos3_g164 );
				half temp_output_29_0_g162 = HatchingSize201;
				half temp_output_20_0_g164 = temp_output_29_0_g162;
				half4 unityObjectToClipPos4_g164 = TransformWorldToHClip(TransformObjectToWorld(float3(0,0,0)));
				half4 computeScreenPos6_g164 = ComputeScreenPos( unityObjectToClipPos4_g164 );
				half4 transform10_g164 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				half2 temp_output_34_0_g162 = ( (int)UseScreenSpace193 == 1 ? (( ( ( ( computeScreenPos5_g164 / (computeScreenPos5_g164).w ) * temp_output_20_0_g164 ) - ( temp_output_20_0_g164 * ( computeScreenPos6_g164 / (computeScreenPos6_g164).w ) ) ) * length( ( half4( _WorldSpaceCameraPos , 0.0 ) - transform10_g164 ) ) )).xy : ( temp_output_29_0_g162 * IN.ase_texcoord3.xy ) );
				float cos15_g162 = cos( HatchingRotation200 );
				float sin15_g162 = sin( HatchingRotation200 );
				half2 rotator15_g162 = mul( temp_output_34_0_g162 - float2( 0,0 ) , float2x2( cos15_g162 , -sin15_g162 , sin15_g162 , cos15_g162 )) + float2( 0,0 );
				half2 break4_g162 = rotator15_g162;
				half2 break31_g162 = float2( 0.5,0 );
				half2 appendResult12_g162 = (half2(( break4_g162.x + ( break31_g162.x * step( 1.0 , ( break4_g162.y % 2.0 ) ) ) ) , ( break4_g162.y + ( break31_g162.y * step( 1.0 , ( break4_g162.x % 2.0 ) ) ) )));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half fresnelNdotV161 = dot( ase_worldNormal, ase_worldViewDir );
				half fresnelNode161 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV161, _FresnelPower ) );
				half fresnelNdotV136 = dot( WorldNormal342, ase_worldViewDir );
				half fresnelNode136 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV136, _FresnelPower ) );
				#ifdef _REALISTIC_FRESNEL
				half staticSwitch152 = ( fresnelNode136 * ase_lightAtten );
				#else
				half staticSwitch152 = fresnelNode161;
				#endif
				half2 appendResult11_g163 = (half2(HatchingWidth199 , staticSwitch152));
				half temp_output_17_0_g163 = length( ( (frac( appendResult12_g162 )*2.0 + -1.0) / appendResult11_g163 ) );
				half4 FresnelValue142 = ( saturate( saturate( ( ( 1.0 - temp_output_17_0_g163 ) / fwidth( temp_output_17_0_g163 ) ) ) ) * _FresnelColor * _FresnelColor.a );
				#ifdef _USE_FRESNEL
				half4 staticSwitch162 = ( FresnelValue142 + staticSwitch250 );
				#else
				half4 staticSwitch162 = staticSwitch250;
				#endif
				half4 unityObjectToClipPos3_g161 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord4.xyz));
				half4 computeScreenPos5_g161 = ComputeScreenPos( unityObjectToClipPos3_g161 );
				half temp_output_29_0_g159 = HatchingSize201;
				half temp_output_20_0_g161 = temp_output_29_0_g159;
				half4 unityObjectToClipPos4_g161 = TransformWorldToHClip(TransformObjectToWorld(float3(0,0,0)));
				half4 computeScreenPos6_g161 = ComputeScreenPos( unityObjectToClipPos4_g161 );
				half4 transform10_g161 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				half2 temp_output_34_0_g159 = ( (int)UseScreenSpace193 == 1 ? (( ( ( ( computeScreenPos5_g161 / (computeScreenPos5_g161).w ) * temp_output_20_0_g161 ) - ( temp_output_20_0_g161 * ( computeScreenPos6_g161 / (computeScreenPos6_g161).w ) ) ) * length( ( half4( _WorldSpaceCameraPos , 0.0 ) - transform10_g161 ) ) )).xy : ( temp_output_29_0_g159 * IN.ase_texcoord3.xy ) );
				float cos15_g159 = cos( HatchingRotation200 );
				float sin15_g159 = sin( HatchingRotation200 );
				half2 rotator15_g159 = mul( temp_output_34_0_g159 - float2( 0,0 ) , float2x2( cos15_g159 , -sin15_g159 , sin15_g159 , cos15_g159 )) + float2( 0,0 );
				half2 break4_g159 = rotator15_g159;
				half2 break31_g159 = float2( 0.5,0 );
				half2 appendResult12_g159 = (half2(( break4_g159.x + ( break31_g159.x * step( 1.0 , ( break4_g159.y % 2.0 ) ) ) ) , ( break4_g159.y + ( break31_g159.y * step( 1.0 , ( break4_g159.x % 2.0 ) ) ) )));
				half3 worldPosValue44_g75 = WorldPosition;
				half3 WorldPosition79_g75 = worldPosValue44_g75;
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 ScreenUV75_g75 = (ase_screenPosNorm).xy;
				half2 ScreenUV79_g75 = ScreenUV75_g75;
				half3 worldNormalValue50_g75 = WorldNormal342;
				half3 WorldNormal79_g75 = worldNormalValue50_g75;
				half3 localAdditionalLightsHalfLambert14x79_g75 = AdditionalLightsHalfLambert14x( WorldPosition79_g75 , ScreenUV79_g75 , WorldNormal79_g75 );
				half3 halfLambertResult58_g75 = localAdditionalLightsHalfLambert14x79_g75;
				half3 temp_output_323_0 = halfLambertResult58_g75;
				half2 appendResult11_g160 = (half2(HatchingWidth199 , temp_output_323_0.x));
				half temp_output_17_0_g160 = length( ( (frac( appendResult12_g159 )*2.0 + -1.0) / appendResult11_g160 ) );
				half temp_output_727_0 = saturate( ( ( 1.0 - temp_output_17_0_g160 ) / fwidth( temp_output_17_0_g160 ) ) );
				#ifdef _OVERRIDE_ADD_LIGHTS_COLOR
				half4 staticSwitch350 = ( temp_output_727_0 * _AddLightsColor * _AddLightsColor.a );
				#else
				half4 staticSwitch350 = half4( ( temp_output_727_0 * temp_output_323_0 ) , 0.0 );
				#endif
				#ifdef _USE_ADDITIONAL_LIGHTS
				half4 staticSwitch328 = ( saturate( staticSwitch350 ) + staticSwitch162 );
				#else
				half4 staticSwitch328 = staticSwitch162;
				#endif
				half4 Color642 = temp_output_160_0;
				#ifdef _INVERT_LINE_SHADOW_COLOR
				half4 staticSwitch640 = Color642;
				#else
				half4 staticSwitch640 = _LineArtShadowColor;
				#endif
				half4 lerpResult511 = lerp( _LineArtMainColor , staticSwitch640 , Shading87);
				#ifdef _OVERRIDE_LINEART_SHADOW
				half4 staticSwitch645 = lerpResult511;
				#else
				half4 staticSwitch645 = _LineArtMainColor;
				#endif
				half4 temp_cast_14 = (_LineArtSmoothstepValues.x).xxxx;
				half4 temp_cast_15 = (_LineArtSmoothstepValues.y).xxxx;
				float2 uv_LineArtMask = IN.ase_texcoord3.xy * _LineArtMask_ST.xy + _LineArtMask_ST.zw;
				half4 smoothstepResult613 = smoothstep( temp_cast_14 , temp_cast_15 , CalculateContrast(_LineArtStrength,SAMPLE_TEXTURE2D( _LineArtMask, sampler_LineArtMask, uv_LineArtMask )));
				half4 temp_cast_16 = (_LineArtSmoothstepValues.x).xxxx;
				half4 temp_cast_17 = (_LineArtSmoothstepValues.y).xxxx;
				half3 Normal544 = tex2DNode532;
				half3 desaturateInitialColor505 = Normal544;
				half desaturateDot505 = dot( desaturateInitialColor505, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar505 = lerp( desaturateInitialColor505, desaturateDot505.xxx, 1.0 );
				half3 temp_output_516_0 = fwidth( desaturateVar505 );
				half4 smoothstepResult485 = smoothstep( temp_cast_16 , temp_cast_17 , CalculateContrast(_LineArtStrength,half4( ( temp_output_516_0 + temp_output_516_0 ) , 0.0 )));
				#ifdef _USE_PROC_LINEART
				half4 staticSwitch638 = saturate( smoothstepResult485 );
				#else
				half4 staticSwitch638 = saturate( smoothstepResult613 );
				#endif
				half4 lerpResult498 = lerp( staticSwitch328 , staticSwitch645 , ( _LineArtMainColor.a * staticSwitch638 ));
				#ifdef _USE_LINEART
				half4 staticSwitch637 = lerpResult498;
				#else
				half4 staticSwitch637 = staticSwitch328;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch637.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = _AlphaCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _LineArtMainColor;
			half4 _MainTex_ST;
			half4 _Tint;
			half4 _ShadowColor;
			half4 _FresnelColor;
			half4 _LineArtShadowColor;
			half4 _HighlightColor;
			half4 _AddLightsColor;
			half4 _NormalMap_ST;
			half4 _LineArtMask_ST;
			half2 _LineArtSmoothstepValues;
			half2 _HatchingMinimumMaximumSize;
			half2 _LightTransition;
			half2 _HighlightTransition;
			half _Cull;
			half _LineArtStrength;
			half _FresnelPower;
			half _NormalStrength;
			half _HighlightStrength;
			half _ShadowStrength;
			half _HatchingWidth;
			half _HatchingRotation;
			half _CompensationDistance;
			half _HatchingSize;
			half _FresnelScale;
			half _AlphaCutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = _AlphaCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _LineArtMainColor;
			half4 _MainTex_ST;
			half4 _Tint;
			half4 _ShadowColor;
			half4 _FresnelColor;
			half4 _LineArtShadowColor;
			half4 _HighlightColor;
			half4 _AddLightsColor;
			half4 _NormalMap_ST;
			half4 _LineArtMask_ST;
			half2 _LineArtSmoothstepValues;
			half2 _HatchingMinimumMaximumSize;
			half2 _LightTransition;
			half2 _HighlightTransition;
			half _Cull;
			half _LineArtStrength;
			half _FresnelPower;
			half _NormalStrength;
			half _HighlightStrength;
			half _ShadowStrength;
			half _HatchingWidth;
			half _HatchingRotation;
			half _CompensationDistance;
			half _HatchingSize;
			half _FresnelScale;
			half _AlphaCutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = _AlphaCutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormals" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _LineArtMainColor;
			half4 _MainTex_ST;
			half4 _Tint;
			half4 _ShadowColor;
			half4 _FresnelColor;
			half4 _LineArtShadowColor;
			half4 _HighlightColor;
			half4 _AddLightsColor;
			half4 _NormalMap_ST;
			half4 _LineArtMask_ST;
			half2 _LineArtSmoothstepValues;
			half2 _HatchingMinimumMaximumSize;
			half2 _LightTransition;
			half2 _HighlightTransition;
			half _Cull;
			half _LineArtStrength;
			half _FresnelPower;
			half _NormalStrength;
			half _HighlightStrength;
			half _ShadowStrength;
			half _HatchingWidth;
			half _HatchingRotation;
			half _CompensationDistance;
			half _HatchingSize;
			half _FresnelScale;
			half _AlphaCutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "Eugeen.ComixShader.ComixArtShaderEditor"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19100
Node;AmplifyShaderEditor.CommentaryNode;644;346.0406,1237.983;Inherit;False;1525.907;400.5967;;7;516;505;360;503;485;731;732;Procedural Line Art;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;643;534.8773,1896.983;Inherit;False;1518.2;423.7197;;4;633;613;629;612;Mask LIne Art;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;334;616.2452,-1273.622;Inherit;False;1513.83;680.4748;;9;331;323;335;336;337;338;340;349;350;Additional Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;252;-1563.454,-1276.889;Inherit;False;2020.291;687.8442;;16;251;174;191;212;176;175;171;207;206;205;195;329;330;332;333;648;Highlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;168;-2122.327,582.0359;Inherit;False;2410.381;1108.531;;23;247;249;231;164;200;199;104;103;99;165;87;108;166;242;246;201;86;196;193;101;117;116;253;Hatching;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;-2606.936,1780.931;Inherit;False;2545.589;1186.306;;16;142;161;136;137;153;151;150;152;144;146;145;194;202;203;204;636;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SaturateNode;144;-854.3796,1812.162;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2469.306,2254.674;Inherit;False;Property;_FresnelScale;Fresnel Scale;21;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-2468.306,2350.675;Inherit;False;Property;_FresnelPower;Fresnel Power;22;0;Create;True;0;0;0;False;0;False;1;8.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;153;-2097.636,2446.992;Inherit;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1769.929,2288.917;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;136;-2187.857,2220.606;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;1.83;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;161;-2187.041,2006.517;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;1.83;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-458.3244,1964.028;Inherit;False;FresnelValue;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-1682.878,1836.896;Inherit;False;193;UseScreenSpace;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-1679.365,1914.474;Inherit;False;201;HatchingSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1680.665,1991.174;Inherit;False;199;HatchingWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1674.165,2070.474;Inherit;False;200;HatchingRotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-177.5348,-128.3925;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2087.631,761.7253;Inherit;False;Property;_HatchingSize;Hatching Size;7;0;Create;True;0;0;0;False;0;False;30;11.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;116;-1498.806,674.8478;Inherit;False;Constant;_Int0;Int 0;7;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;117;-1501.806,752.8478;Inherit;False;Constant;_Int1;Int 0;7;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-1079.148,649.1188;Inherit;False;UseScreenSpace;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-1103.323,754.9235;Inherit;False;193;UseScreenSpace;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-1142.868,847.3447;Inherit;False;HatchingSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-1320.36,1176.181;Inherit;False;HatchingWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-1300.76,1270.181;Inherit;False;HatchingRotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;246;-1653.713,853.544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;70;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;227.3857,39.86312;Inherit;False;142;FresnelValue;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-1028.532,-860.3544;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;-710.3834,-243.2663;Inherit;False;Property;_Tint;Tint;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;152;-1581.215,2165.546;Inherit;False;Property;_RealisticFresnel;Realistic Fresnel;19;0;Create;True;0;0;0;False;0;False;0;1;1;True;_REALISTIC_FRESNEL;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;231;-1785.266,852.4752;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;242;-2021.283,921.316;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;253;-2115.172,837.2408;Inherit;False;Property;_CompensationDistance;Compensation Distance;5;0;Create;True;0;0;0;False;0;False;0;1.45;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;249;-2013.493,1060.419;Inherit;False;Property;_HatchingMinimumMaximumSize;Hatching Minimum Maximum Size;6;0;Create;True;0;0;0;False;1;ShowAsVector2;False;0,0;10,100;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;166;-305.1452,955.6473;Inherit;False;Property;_Crosshatching;Crosshatching;10;0;Create;True;0;0;0;False;0;False;0;0;0;True;_CROSSHATCHING;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1621.978,1181.88;Inherit;False;Property;_HatchingWidth;Hatching Width;8;0;Create;True;0;0;0;False;0;False;3;10;0.5;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;106;-1173.128,361.5811;Inherit;False;Property;_LightTransition;Light Transition;13;0;Create;True;0;0;0;False;0;False;0.45,0.67;0.12,0.6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;212;-1257.681,-721.4181;Inherit;False;Property;_HighlightStrength;Highlight Strength;16;0;Create;True;0;0;0;False;0;False;1;10.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-337.2495,-341.8816;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1509.539,1270.277;Inherit;False;Property;_HatchingRotation;Hatching Rotation;9;0;Create;True;0;0;0;False;0;False;1;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;165;-436.7704,980.4265;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;-25.78953,930.9758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-701.17,2123.327;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;145;-1152.877,2150.83;Inherit;False;Property;_FresnelColor;Fresnel Color;20;0;Create;True;0;0;0;False;0;False;0.627937,0.9716981,0.9359638,1;1,0.8345173,0.1572326,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1246.845,84.70256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-855.3777,-24.55876;Inherit;False;Property;_ShadowStrength;Shadow Strength;12;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-547.4894,-59.73046;Inherit;False;87;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1149.396,990.6373;Inherit;False;325;Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;247;-1481.289,834.8783;Inherit;False;Property;_CompensateDistance;Compensate Distance;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;_COMPENSATE_DISTANCE;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;174;-611.1022,-1239.826;Inherit;False;Property;_HighlightColor;Highlight Color;15;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.9392058,0.6477987,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;-299.9107,-1081.926;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;156;-27.67869,-246.2248;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;332;-273.036,-837.2724;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-1023.987,-1230.941;Inherit;False;193;UseScreenSpace;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-1054.768,-956.1052;Inherit;False;200;HatchingRotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-1056.068,-1116.005;Inherit;False;201;HatchingSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-1052.169,-1043.205;Inherit;False;199;HatchingWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;729.4906,-1246.048;Inherit;False;193;UseScreenSpace;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;336;698.7097,-971.2119;Inherit;False;200;HatchingRotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;337;697.4096,-1131.112;Inherit;False;201;HatchingSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;701.3087,-1058.311;Inherit;False;199;HatchingWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;628.5313,-13.08438;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;162;869.7465,-239.4947;Inherit;True;Property;_UseFresnel;Use Fresnel;18;0;Create;True;0;0;0;False;0;False;0;0;0;True;_USE_FRESNEL;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;331;1830.359,-715.4055;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;1368.588,-773.5359;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;333;-631.2755,-785.2918;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;-400.6631,-941.2267;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;26;-847.3865,98.605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;97;-930.0919,294.7583;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.04;False;2;FLOAT;0.35;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-592.7607,110.698;Inherit;True;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;-359.3343,100.3654;Inherit;False;Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;101;-1343.723,664.0433;Inherit;False;Property;_UseScreenSpace;Use Screen Space;3;0;Create;True;0;0;0;False;0;False;0;1;1;True;_USE_SCREEN_SPACE;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;529;-3369.249,208.6669;Inherit;True;Property;_NormalMap;Normal Map;29;1;[Normal];Create;True;0;0;0;False;0;False;8e67f0752d99b3e41b30d455b6ddfbbb;6ed69f436399aeb40823512bae4e8a5f;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;244;-3349.687,410.0252;Inherit;False;Property;_NormalStrength;Normal Strength;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;532;-3133.102,231.7018;Inherit;True;Property;_TextureSample0;Texture Sample 0;33;1;[Normal];Create;True;0;0;0;False;0;False;-1;8e67f0752d99b3e41b30d455b6ddfbbb;8e67f0752d99b3e41b30d455b6ddfbbb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;544;-2819.054,443.0756;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;77;-2763.576,259.2553;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;342;-2488.89,296.6673;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;636;-2480.143,2159.81;Inherit;False;342;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;341;1201.626,-296.9587;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;328;1417.217,-145.9976;Inherit;False;Property;_UseAdditionalLights;Use Additional Lights;25;0;Create;True;0;0;0;False;0;False;0;0;0;True;_USE_ADDITIONAL_LIGHTS;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;329;-180.8304,-972.5977;Inherit;False;Property;_OverrideMainLightColor;Override Main Light Color;26;0;Create;True;0;0;0;False;0;False;0;0;0;True;_OVERRIDE_MAIN_LIGHT_COLOR;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;191;173.3985,-937.5956;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;349;1113.7,-790.6831;Inherit;False;Property;_AddLightsColor;AddLightsColor;27;0;Create;True;0;0;0;True;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;266;510.0945,429.4489;Inherit;False;Property;_Cull;Cull;24;0;Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;164;-1029.354,1290.577;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2739.554,-67.78934;Half;False;True;-1;2;Eugeen.ComixShader.ComixArtShaderEditor;0;13;Eugeen/ComixShader;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;True;0;True;_Cull;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;638342144276947087;Forward Only;0;638343384707204550;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;638346006204456278;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;638346012949180324;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;True;True;True;True;False;False;False;False;True;False;False;;True;0
Node;AmplifyShaderEditor.RangedFloatNode;257;2528.349,267.389;Inherit;False;Property;_AlphaCutoff;Alpha Cutoff;23;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;498;2123.251,50.18229;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;159;-796.7924,-438.0291;Inherit;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;0;False;0;False;-1;None;14b68e3e3dd6ae24cb1240badec6adbe;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;642;-149.1869,-360.0434;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;613;1404.901,1983.158;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;633;1728.941,1992.013;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;2046.338,708.9989;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;641;1128.077,383.6595;Inherit;False;642;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;507;1467.248,447.9446;Inherit;False;87;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;499;1457.243,133.2947;Inherit;False;Property;_LineArtMainColor;Line Art Main Color;33;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;640;1346.253,324.4035;Inherit;False;Property;_InvertLineArtShadowColor;Invert Line Art Shadow Color ;37;0;Create;True;0;0;0;False;0;False;0;0;0;True;_INVERT_LINE_SHADOW_COLOR;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;512;1073.2,218.1285;Inherit;False;Property;_LineArtShadowColor;Line Art Shadow Color;32;0;Create;True;0;0;0;False;0;False;0.2904586,0.03631186,0.4528302,1;0.1921568,0.2478319,0.5764706,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;514;839.5499,1719.008;Inherit;False;Property;_LineArtStrength;Line Art Strength;31;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;639;1087.913,1698.868;Inherit;False;Property;_LineArtSmoothstepValues;Line Art Smoothstep Values;36;0;Create;True;0;0;0;False;0;False;0,1;0.03,0.26;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;511;1686.835,283.3815;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;645;1792.94,154.3664;Inherit;False;Property;_OverrideLineArtShadowColor;Override Line Art Shadow Color;38;0;Create;True;0;0;0;False;0;False;0;1;1;True;_OVERRIDE_LINEART_SHADOW;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;340;1392.708,-927.8741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;633.9659,-866.6509;Inherit;False;342;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;323;818.1664,-873.6888;Inherit;True;SRP Additional Light;-1;;75;6c86746ad131a0a408ca599df5f40861;7,6,1,9,1,23,1,27,0,25,0,24,0,26,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;350;1532.688,-852.936;Inherit;False;Property;_OverrideAdditionalLightsColor;Override Additional Lights Color;28;0;Create;True;0;0;0;False;0;False;0;1;1;True;_OVERRIDE_ADD_LIGHTS_COLOR;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;250;383.7237,-253.369;Inherit;False;Property;_UseHighlight;Use Highlight;14;0;Create;True;0;0;0;False;0;False;0;0;0;True;_USE_HIGHLIGHT;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;637;2456.821,-105.2526;Inherit;False;Property;_UseLineArt;Use Line Art;34;0;Create;True;0;0;0;False;0;False;0;1;1;True;_USE_LINEART;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;638;1919.189,1358.918;Inherit;False;Property;_UseProceduralLineArt;Use Procedural Line Art;35;0;Create;True;0;0;0;False;0;False;0;1;1;True;_USE_PROC_LINEART;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;629;1067.911,2048.462;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;2;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;175;-1547.736,-1171.797;Inherit;False;Property;_HighlightTransition;Highlight Transition;17;0;Create;True;0;0;0;False;0;False;0.8,0.9;0.34,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;171;-1409.382,-1005.911;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.54;False;2;FLOAT;0.58;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;635;-2173.995,316.3304;Inherit;False;342;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;657;-1526.129,-90.69519;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;648;-1180.203,-882.0765;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;654;-1485.692,163.0924;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;11;-1841.319,-81.50237;Inherit;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;12;-1900.617,214.1267;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;13;-2217.325,67.80604;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;658;-2226.484,-211.6869;Inherit;True;Property;_TextureSample1;Texture Sample 1;39;0;Create;True;0;0;0;False;0;False;-1;2f46f1fd27f499741810a3c7957a4bd9;2f46f1fd27f499741810a3c7957a4bd9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;725;-798.7938,1150.292;Inherit;True;Hatching;-1;;153;513754f8c75b3004e92d4317a0625608;0;6;32;INT;0;False;29;FLOAT;30;False;30;FLOAT2;0.5,0;False;26;FLOAT;0.46;False;27;FLOAT;1.5;False;28;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;726;-764.129,-1053.317;Inherit;True;Hatching;-1;;156;513754f8c75b3004e92d4317a0625608;0;6;32;INT;0;False;29;FLOAT;30;False;30;FLOAT2;0.5,0;False;26;FLOAT;0.46;False;27;FLOAT;1.5;False;28;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;727;1020.349,-1088.424;Inherit;True;Hatching;-1;;159;513754f8c75b3004e92d4317a0625608;0;6;32;INT;0;False;29;FLOAT;30;False;30;FLOAT2;0.5,0;False;26;FLOAT;0.46;False;27;FLOAT;1.5;False;28;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;728;-1280.051,1879.88;Inherit;True;Hatching;-1;;162;513754f8c75b3004e92d4317a0625608;0;6;32;INT;0;False;29;FLOAT;30;False;30;FLOAT2;0.5,0;False;26;FLOAT;0.46;False;27;FLOAT;1.5;False;28;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;729;-819.2227,906.5498;Inherit;True;Hatching;-1;;165;513754f8c75b3004e92d4317a0625608;0;6;32;INT;0;False;29;FLOAT;30;False;30;FLOAT2;0.5,0;False;26;FLOAT;0.46;False;27;FLOAT;1.5;False;28;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1301.851,747.8575;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;0;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SamplerNode;612;642.6024,2032.804;Inherit;True;Property;_LineArtMask;_LineArtMask;30;0;Create;True;0;0;0;True;0;False;-1;None;2239c876666fcb343bb48ca155b826e2;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;85.55836,834.3169;Inherit;False;Shading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;158;-394.158,-241.7236;Inherit;False;Property;_ShadowColor;Shadow Color;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.06274509,0.1495854,0.1882353,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;505;701.386,1280.689;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;360;475.3817,1309.646;Inherit;True;544;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;503;1682.865,1366.307;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;485;1429.042,1384.714;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.43,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FWidthOpNode;516;945.8079,1285.439;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;732;1163.883,1299.244;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;731;1175.895,1498.776;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
WireConnection;144;0;728;0
WireConnection;137;0;136;0
WireConnection;137;1;153;0
WireConnection;136;0;636;0
WireConnection;136;2;150;0
WireConnection;136;3;151;0
WireConnection;161;2;150;0
WireConnection;161;3;151;0
WireConnection;142;0;146;0
WireConnection;170;0;158;4
WireConnection;170;1;88;0
WireConnection;193;0;101;0
WireConnection;201;0;247;0
WireConnection;199;0;103;0
WireConnection;200;0;104;0
WireConnection;246;0;231;0
WireConnection;246;1;249;1
WireConnection;246;2;249;2
WireConnection;176;0;648;0
WireConnection;176;1;212;0
WireConnection;152;1;161;0
WireConnection;152;0;137;0
WireConnection;231;0;99;0
WireConnection;231;1;242;0
WireConnection;242;0;253;0
WireConnection;166;1;729;0
WireConnection;166;0;165;0
WireConnection;160;0;159;0
WireConnection;160;1;157;0
WireConnection;165;0;729;0
WireConnection;165;1;725;0
WireConnection;108;0;166;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;146;2;145;4
WireConnection;14;0;11;0
WireConnection;14;1;12;0
WireConnection;247;1;99;0
WireConnection;247;0;246;0
WireConnection;251;0;174;0
WireConnection;251;1;726;0
WireConnection;251;2;174;4
WireConnection;156;0;160;0
WireConnection;156;1;158;0
WireConnection;156;2;170;0
WireConnection;332;0;330;0
WireConnection;147;0;143;0
WireConnection;147;1;250;0
WireConnection;162;1;250;0
WireConnection;162;0;147;0
WireConnection;331;0;350;0
WireConnection;351;0;727;0
WireConnection;351;1;349;0
WireConnection;351;2;349;4
WireConnection;330;0;726;0
WireConnection;330;1;333;0
WireConnection;330;2;333;2
WireConnection;26;0;97;0
WireConnection;97;0;14;0
WireConnection;97;1;106;1
WireConnection;97;2;106;2
WireConnection;27;0;107;0
WireConnection;27;1;26;0
WireConnection;325;0;27;0
WireConnection;101;1;116;0
WireConnection;101;0;117;0
WireConnection;532;0;529;0
WireConnection;532;5;244;0
WireConnection;544;0;532;0
WireConnection;77;0;532;0
WireConnection;342;0;77;0
WireConnection;341;0;331;0
WireConnection;341;1;162;0
WireConnection;328;1;162;0
WireConnection;328;0;341;0
WireConnection;329;1;332;0
WireConnection;329;0;251;0
WireConnection;191;0;156;0
WireConnection;191;1;329;0
WireConnection;191;2;329;0
WireConnection;164;0;200;0
WireConnection;1;2;637;0
WireConnection;1;4;257;0
WireConnection;498;0;328;0
WireConnection;498;1;645;0
WireConnection;498;2;506;0
WireConnection;642;0;160;0
WireConnection;613;0;629;0
WireConnection;613;1;639;1
WireConnection;613;2;639;2
WireConnection;633;0;613;0
WireConnection;506;0;499;4
WireConnection;506;1;638;0
WireConnection;640;1;512;0
WireConnection;640;0;641;0
WireConnection;511;0;499;0
WireConnection;511;1;640;0
WireConnection;511;2;507;0
WireConnection;645;1;499;0
WireConnection;645;0;511;0
WireConnection;340;0;727;0
WireConnection;340;1;323;0
WireConnection;323;11;343;0
WireConnection;350;1;340;0
WireConnection;350;0;351;0
WireConnection;250;1;156;0
WireConnection;250;0;191;0
WireConnection;637;1;328;0
WireConnection;637;0;498;0
WireConnection;638;1;633;0
WireConnection;638;0;503;0
WireConnection;629;1;612;0
WireConnection;629;0;514;0
WireConnection;171;0;14;0
WireConnection;171;1;175;1
WireConnection;171;2;175;2
WireConnection;657;0;658;1
WireConnection;657;1;12;0
WireConnection;648;0;171;0
WireConnection;654;0;11;0
WireConnection;654;1;657;0
WireConnection;12;0;13;0
WireConnection;12;1;635;0
WireConnection;725;32;196;0
WireConnection;725;29;201;0
WireConnection;725;26;86;0
WireConnection;725;27;199;0
WireConnection;725;28;164;0
WireConnection;726;32;195;0
WireConnection;726;29;206;0
WireConnection;726;26;176;0
WireConnection;726;27;207;0
WireConnection;726;28;205;0
WireConnection;727;32;335;0
WireConnection;727;29;337;0
WireConnection;727;26;323;0
WireConnection;727;27;338;0
WireConnection;727;28;336;0
WireConnection;728;32;194;0
WireConnection;728;29;202;0
WireConnection;728;26;152;0
WireConnection;728;27;203;0
WireConnection;728;28;204;0
WireConnection;729;32;196;0
WireConnection;729;29;201;0
WireConnection;729;26;86;0
WireConnection;729;27;199;0
WireConnection;729;28;200;0
WireConnection;87;0;108;0
WireConnection;505;0;360;0
WireConnection;503;0;485;0
WireConnection;485;0;731;0
WireConnection;485;1;639;1
WireConnection;485;2;639;2
WireConnection;516;0;505;0
WireConnection;732;0;516;0
WireConnection;732;1;516;0
WireConnection;731;1;732;0
WireConnection;731;0;514;0
ASEEND*/
//CHKSM=48E2ECE96EE6C7C654F4E324397B1CE94F48EF73