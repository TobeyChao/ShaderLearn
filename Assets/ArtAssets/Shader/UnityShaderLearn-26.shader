// Texture Anim
Shader "UnityShaderLearn/ShaderLearn-25"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1.0
		_Saturation ("Saturation", Float) = 1.0
		_Contrast ("Contrast", Float) = 1.0
	}
	SubShader
	{
		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			ZWrite Off
			ZTest Always
			Cull Off
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
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
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed4 renderTex = tex2D(_MainTex, input.uv);
				fixed3 finalColor = renderTex.rgb * _Brightness;

				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

				return fixed4(finalColor, renderTex.a);
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}