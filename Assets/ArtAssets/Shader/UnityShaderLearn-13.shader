// ZWrite On

Shader "UnityShaderLearn/ShaderLearn-13"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1.0
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		pass
		{
			ZWrite on
			ColorMask 0
		}
		pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _AlphaScale;

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
				outPut.positionW = mul(UNITY_MATRIX_M,  input.positionL);
				outPut.normalW = UnityObjectToWorldNormal(input.normalL);
				outPut.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 worldNormal = normalize(input.normalW);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed4 texColor = tex2D(_MainTex, input.uv).rgba;
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				float diffuseFactor = saturate(dot(worldLightDir, worldNormal));
				//float diffuseFactor = dot(worldLightDir, worldNormal) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * diffuseFactor;
				fixed3 color = ambientColor + diffuseColor;
				return fixed4(color, texColor.a * _AlphaScale);
			}
			ENDCG
		}
	}
}