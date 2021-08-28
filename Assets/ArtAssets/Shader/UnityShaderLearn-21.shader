// Glass
Shader "UnityShaderLearn/ShaderLearn-21"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}
		_Cubemap ("Cubemap", Cube) = "skybox" {}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Opaque"
		}
		GrabPass { "_RefractionTex" }
		pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "Autolight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 srcPos : TEXCOORD0;
				float3 normalW : NORMAL;
				float3 biNormalW : BINORMAL;
				float3 tangentW : TANGENT;
				float3 positionW : TEXCOORD1;
				float2 uv : TEXCOORD2;
				float2 bump_uv : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.srcPos = ComputeGrabScreenPos(o.pos);
				o.positionW = mul(UNITY_MATRIX_M, v.vertex);
				o.normalW = UnityObjectToWorldNormal(v.normal);
				o.tangentW = UnityObjectToWorldDir(v.tangent.xyz);
				o.biNormalW = cross(o.normalW, o.tangentW) * v.tangent.w;

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.bump_uv = TRANSFORM_TEX(v.texcoord, _BumpMap);

				return o;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				float3 bump = UnpackNormal(tex2D(_BumpMap, input.bump_uv));
				
				// Compute the offset in tangent space
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				input.srcPos.xy = offset * input.srcPos.z + input.srcPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, input.srcPos.xy / input.srcPos.w).rgb;

				// 将凹凸法向量从切线空间变换到世界坐标系
    			// 方法1.构建位于世界坐标系的切线空间
				float3 T = input.tangentW;
				float3 N = input.normalW;
    			float3 B = input.biNormalW;
    			float3x3 TBN = transpose(float3x3(T, B, N));
				fixed3 worldNormal = normalize(mul(TBN, bump));

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.positionW.xyz));
				fixed3 worldRefl = reflect(-viewDir, worldNormal);
				fixed4 texColor = tex2D(_MainTex, input.uv);
				fixed3 reflectionColor = texCUBE(_Cubemap, worldRefl).rgb * texColor.rgb;
				
				fixed3 color = reflectionColor * (1 - _RefractAmount) + _RefractAmount * refrCol;
				return fixed4(color, 1.0f);
			}
			ENDCG
		}
	}
	//FallBack "Reflective/VertexLit"
}