// Texture Anim
Shader "UnityShaderLearn/ShaderLearn-24"
{
	Properties
	{
		_BaseLayer ("BaseLayer", 2D) = "white" {}
		_FrontLayer ("FrontLayer", 2D) = "white" {}
		_ScrollX ("BaseLayer Scroll Speed", Float) = 1.0
		_Scroll2X ("FrontLayer Scroll2 Speed", Float) = 1.0
		_Multiplier ("Multiplier", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		/*
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}*/
		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			//ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			sampler2D _BaseLayer;
			float4 _BaseLayer_ST;
			sampler2D _FrontLayer;
			float4 _FrontLayer_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 base_uv : TEXCOORD0;
				float2 front_uv : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.base_uv = TRANSFORM_TEX(v.texcoord, _BaseLayer) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.front_uv = TRANSFORM_TEX(v.texcoord, _FrontLayer) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed4 base_color = tex2D(_BaseLayer, input.base_uv);
				fixed4 front_color = tex2D(_FrontLayer, input.front_uv);
				fixed4 color = lerp(base_color, front_color, front_color.a);
				color.rgb *= _Multiplier;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}