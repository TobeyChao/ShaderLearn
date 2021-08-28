// Specular Mask
Shader "UnityShaderLearn/ShaderLearn-10"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss ("Gloss", Range(8.0, 256.0)) = 20
	}
	SubShader
	{
		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
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
				fixed specularMask = tex2D(_SpecularMask, input.uv).r * _SpecularScale;
				// 高光反向穿透问题
				//specularFactor *= step(0, dot(worldLightDir, worldNormal));
				specularFactor *= smoothstep(0, 0.12, dot(worldLightDir, worldNormal));
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specularFactor * specularMask;
				fixed3 color = ambientColor + diffuseColor + specularColor;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
}