// Fresnel relection
Shader "UnityShaderLearn/ShaderLearn-19"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
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
			fixed _FresnelScale;
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

				fixed3 worldRefl = reflect(-UnityWorldSpaceViewDir(input.positionW.xyz), input.normalW);
				fixed3 reflectionColor = texCUBE(_Cubemap, worldRefl).rgb;
				
				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(viewDir, worldNormal), 5);

				UNITY_LIGHT_ATTENUATION(atten, input, input.positionW);
				fixed3 color = ambientColor + lerp(diffuseColor, reflectionColor, saturate(fresnel)) * atten;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}