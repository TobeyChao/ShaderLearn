// Refraction
Shader "UnityShaderLearn/ShaderLearn-18"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RefractColor ("Refract Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RefractAmount ("Refract Amount", Range(0, 1)) = 1
		_RefractRatio ("Refract Ratio", Range(0.1, 1)) = 0.5
		_Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
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
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
            fixed _RefractAmount;
			fixed _RefractRatio;
			samplerCUBE _Cubemap;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normalW : NORMAL;
				float3 positionW : TEXCOORD0;
				SHADOW_COORDS(1)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.positionW = mul(UNITY_MATRIX_M, v.vertex);
				o.normalW = UnityObjectToWorldNormal(v.normal);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 worldNormal = normalize(input.normalW);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(input.positionW.xyz));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.positionW.xyz));
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float diffuseFactor = saturate(dot(worldLightDir, worldNormal));
				//float diffuseFactor = dot(worldLightDir, worldNormal) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * diffuseFactor;
				fixed3 worldRefr = refract(-viewDir, input.normalW, _RefractRatio);
				fixed3 refractionColor = texCUBE(_Cubemap, worldRefr).rgb * _RefractColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten, input, input.positionW);
				fixed3 color = ambientColor + lerp(diffuseColor, refractionColor, _RefractAmount) * atten;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}