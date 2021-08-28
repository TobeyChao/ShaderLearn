// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Forward Rendering
Shader "UnityShaderLearn/ShaderLearn-15-1"
{
	
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss ("Gloss", Range(8.0, 256.0)) = 20
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
            #include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 positionL : POSITION;
				float3 normalL : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
				float2 bump_texcoord : TEXCOORD1;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 normalW : NORMAL;
				float3 biNormalW : BINORMAL;
				float3 tangentW : TANGENT;
				float3 positionW : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float2 bump_uv : TEXCOORD2;
				float3 TtoW0 : TEXCOORD3;
				float3 TtoW1 : TEXCOORD4;
				float3 TtoW2 : TEXCOORD5;
                float3 vertexLighting : TEXCOORD6;
                LIGHTING_COORDS(7, 8)
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.positionL);
				outPut.positionW = mul(UNITY_MATRIX_M, input.positionL);
				outPut.normalW = UnityObjectToWorldNormal(input.normalL);
				outPut.tangentW = UnityObjectToWorldDir(input.tangent.xyz);
				outPut.biNormalW = cross(outPut.normalW, outPut.tangentW) * input.tangent.w;

				outPut.uv = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; //TRANSFORM_TEX(input.texcoord, _MainTex);
				outPut.bump_uv = input.bump_texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //TRANSFORM_TEX(input.texcoord, _MainTex);
				
				outPut.TtoW0 = float3(outPut.tangentW.x, outPut.biNormalW.x, outPut.normalW.x);
				outPut.TtoW1 = float3(outPut.tangentW.y, outPut.biNormalW.y, outPut.normalW.y);
				outPut.TtoW2 = float3(outPut.tangentW.z, outPut.biNormalW.z, outPut.normalW.z);
				
                outPut.vertexLighting = float3(0.0, 0.0, 0.0);

                // SH/ambient and vertex lights
                #ifdef LIGHTMAP_OFF
                float3 shLight = ShadeSH9 (float4(outPut.normalW, 1.0));
                outPut.vertexLighting = shLight;
                #ifdef VERTEXLIGHT_ON
                float3 vertexLight = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, outPut.positionW, outPut.normalW);
                outPut.vertexLighting += vertexLight;

                // pass lighting information to pixel shader
                TRANSFER_VERTEX_TO_FRAGMENT(outPut);
                #endif // VERTEXLIGHT_ON
                #endif // LIGHTMAP_OFF
                
                return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				
    			float3 bump = UnpackNormal(tex2D(_BumpMap, input.bump_uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

    			// 将凹凸法向量从切线空间变换到世界坐标系
    			// 方法1.构建位于世界坐标系的切线空间
				float3 T = input.tangentW;
				float3 N = input.normalW;
    			float3 B = input.biNormalW;
    			float3x3 TBN = transpose(float3x3(T, B, N));
				fixed3 worldNormal = normalize(mul(TBN, bump));
				// 方法2.向量点乘 其实和矩阵乘法计算一样
				//fixed3 worldNormal = normalize(half3(dot(input.TtoW0, bump), dot(input.TtoW1, bump), dot(input.TtoW2, bump)));
				
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float diffuseFactor = saturate(dot(worldLightDir, worldNormal));
				//float diffuseFactor = dot(worldLightDir, worldNormal) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * diffuseFactor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.positionW.xyz));
				// Phong
				//fixed3 reflectLightDir = normalize(reflect(-worldLightDir, worldNormal));
				//float specularFactor = pow(max(0, dot(reflectLightDir, viewDir)), _Gloss);
				// Blinn-Phong
				fixed3 halfDir =  normalize(viewDir + worldLightDir);
				float specularFactor = pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				// 高光反向穿透问题
				//specularFactor *= step(0, dot(worldLightDir, worldNormal));
				specularFactor *= smoothstep(0, 0.12, dot(worldLightDir, worldNormal));
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specularFactor;
				fixed atten = 1.0;
				fixed3 color = ambientColor + (diffuseColor + specularColor) * atten;
				//return fixed4(color, 1.0f);
                return fixed4(input.vertexLighting, 1.0f);
			}
			ENDCG
		}

		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardAdd"
			}
			
			Blend One One

			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 positionL : POSITION;
				float3 normalL : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
				float2 bump_texcoord : TEXCOORD1;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 normalW : NORMAL;
				float3 biNormalW : BINORMAL;
				float3 tangentW : TANGENT;
				float3 positionW : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float2 bump_uv : TEXCOORD2;
				float3 TtoW0 : TEXCOORD3;
				float3 TtoW1 : TEXCOORD4;
				float3 TtoW2 : TEXCOORD5;
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.positionL);
				outPut.positionW = mul(UNITY_MATRIX_M, input.positionL);
				outPut.normalW = UnityObjectToWorldNormal(input.normalL);
				outPut.tangentW = UnityObjectToWorldDir(input.tangent.xyz);
				outPut.biNormalW = cross(outPut.normalW, outPut.tangentW) * input.tangent.w;

				outPut.uv = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; //TRANSFORM_TEX(input.texcoord, _MainTex);
				outPut.bump_uv = input.bump_texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //TRANSFORM_TEX(input.texcoord, _MainTex);
				
				outPut.TtoW0 = float3(outPut.tangentW.x, outPut.biNormalW.x, outPut.normalW.x);
				outPut.TtoW1 = float3(outPut.tangentW.y, outPut.biNormalW.y, outPut.normalW.y);
				outPut.TtoW2 = float3(outPut.tangentW.z, outPut.biNormalW.z, outPut.normalW.z);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;
				
    			float3 bump = UnpackNormal(tex2D(_BumpMap, input.bump_uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

    			// 将凹凸法向量从切线空间变换到世界坐标系
    			// 方法1.构建位于世界坐标系的切线空间
				float3 T = input.tangentW;
				float3 N = input.normalW;
    			float3 B = input.biNormalW;
    			float3x3 TBN = transpose(float3x3(T, B, N));
				fixed3 worldNormal = normalize(mul(TBN, bump));
				// 方法2.向量点乘 其实和矩阵乘法计算一样
				//fixed3 worldNormal = normalize(half3(dot(input.TtoW0, bump), dot(input.TtoW1, bump), dot(input.TtoW2, bump)));
				#ifdef USING_DIRECTIONAL_LIGHTT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - input.positionW.xyz);
				#endif
				float diffuseFactor = saturate(dot(worldLightDir, worldNormal));
				//float diffuseFactor = dot(worldLightDir, worldNormal) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * diffuseFactor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.positionW.xyz));
				// Phong
				//fixed3 reflectLightDir = normalize(reflect(-worldLightDir, worldNormal));
				//float specularFactor = pow(max(0, dot(reflectLightDir, viewDir)), _Gloss);
				// Blinn-Phong
				fixed3 halfDir =  normalize(viewDir + worldLightDir);
				float specularFactor = pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				// 高光反向穿透问题
				//specularFactor *= step(0, dot(worldLightDir, worldNormal));
				specularFactor *= smoothstep(0, 0.12, dot(worldLightDir, worldNormal));
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specularFactor;
				#ifdef USING_DIRECTIONAL_LIGHTT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(input.positionW, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(input.positionW, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif
				fixed3 color = (diffuseColor + specularColor) * atten;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
}