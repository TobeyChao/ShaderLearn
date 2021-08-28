// Texture Mapping
Shader "UnityShaderLearn/ShaderLearn-07"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
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
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 positionL : POSITION;
				float3 normalL : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 normalW : NORMAL;
				float3 positionW : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.positionL);
				outPut.positionW = mul(UNITY_MATRIX_M, input.positionL);
				outPut.normalW = UnityObjectToWorldNormal(input.normalL);
				outPut.uv = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; //TRANSFORM_TEX(input.texcoord, _MainTex);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 worldNormal = normalize(input.normalW);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float diffuseFactor = saturate(dot(worldLightDir, worldNormal));
				//float diffuseFactor = dot(worldLightDir, worldNormal) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * diffuseFactor;
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.positionW.xyz));
				// Phong
				fixed3 reflectLightDir = normalize(reflect(-worldLightDir, worldNormal));
				float specularFactor = pow(max(0, dot(reflectLightDir, viewDir)), _Gloss);
				// Blinn-Phong
				//fixed3 halfDir =  normalize(viewDir + worldLightDir);
				//float specularFactor = pow(max(0, dot(halfDir, worldNormal)), _Gloss);
				// 高光反向穿透问题
				//specularFactor *= step(0, dot(worldLightDir, worldNormal));
				specularFactor *= smoothstep(0, 0.12, dot(worldLightDir, worldNormal));
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specularFactor;
				fixed3 color = ambientColor + diffuseColor + specularColor;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
}