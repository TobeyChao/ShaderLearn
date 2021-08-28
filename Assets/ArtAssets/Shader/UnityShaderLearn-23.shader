// Texture Anim
Shader "UnityShaderLearn/ShaderLearn-23"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Image Sequence", 2D) = "white" {}
		_HorizontalAmount ("Horizontal Amount", Float) = 4
		_VerticalAmount ("Vertical Amount", Float) = 4
		_Speed ("Speed", Range(0, 100)) = 30
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
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
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
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				float frame = floor(_Time.y * _Speed);
				// 在第几行
				float row = floor(frame / _HorizontalAmount);
				// 在第几列
				float column = frame - row * _HorizontalAmount;
				// 放缩u(v)到1/_HorizontalAmount(1/_VerticalAmount)
				half2 uv = float2(input.uv.x / _HorizontalAmount, input.uv.y / _VerticalAmount);
				// 加上行列的偏移
				uv.x += column / _HorizontalAmount;
				uv.y -= row / _VerticalAmount;
				fixed4 color = tex2D(_MainTex, uv);
				color.rgb *= _Color;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}