// Diffuse
Shader "UnityShaderLearn/ShaderLearn-05"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
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

			fixed4 _Diffuse;

			struct a2v
			{
				float4 positionL : POSITION;
				float3 normalL : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 normalW : NORMAL;
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.positionL);
				outPut.normalW = UnityObjectToWorldNormal(input.normalL);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
				float diffuseFactor = saturate(dot(_WorldSpaceLightPos0.xyz, input.normalW));
				//float diffuseFactor = dot(_WorldSpaceLightPos0.xyz, input.normalW) * 0.5f + 0.5f;
				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * diffuseFactor;
				fixed3 color = ambientColor + diffuseColor;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
}