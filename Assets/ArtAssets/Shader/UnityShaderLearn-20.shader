// Mirror
Shader "UnityShaderLearn/ShaderLearn-20"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader
	{
		pass
		{
			Tags
			{
				 "RenderType" = "Opaque"
				 "Queue" = "Geometry"
			}
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			sampler2D _MainTex;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv.x = 1 - o.uv.x;
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				return tex2D(_MainTex, input.uv);
			}
			ENDCG
		}
	}
	//FallBack "Reflective/VertexLit"
}