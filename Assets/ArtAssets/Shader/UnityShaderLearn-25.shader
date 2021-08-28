// Texture Anim
Shader "UnityShaderLearn/ShaderLearn-25"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Magnitude ("Magnitude", Float) = 1.0
		_Frequency ("Frequency", Float) = 1.0
		_WaveNumber ("Wave Number", Float) = 10.0
		_Speed ("Speed", Float) = 1.0
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"DisableBatching" = "True"
		}
		pass
		{
			Tags
			{ 
				"LightMode" = "ForwardBase"
			}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _WaveNumber;
			float _Speed;

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
				float4 offset;
				offset.yzw = float3(0.0f, 0.0f, 0.0f);
				offset.x = sin(_Frequency * 1 / _WaveNumber * _Time.y + v.vertex.x * _WaveNumber + v.vertex.y * _WaveNumber + v.vertex.z * _WaveNumber) * _Magnitude;
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(0.0, _Speed) * _Time.y);
				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				fixed4 color = tex2D(_MainTex, input.uv);
				color.rgb *= _Color.rgb;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}