// Ambient
Shader "UnityShaderLearn/ShaderLearn-04"
{
	Properties
	{
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

			struct a2v
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.vertex);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
				return fixed4(ambientColor, 1.0f);
			}
			ENDCG
		}
	}
}