Shader "UnityShaderLearn/ShaderLearn-02"
{
	SubShader
	{
		pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 color : COLOR0;
			};

			v2f vert(a2v input)
			{
				v2f outPut;
				outPut.position = UnityObjectToClipPos(input.vertex);
				outPut.color = input.normal * 0.5f + fixed3(0.5f, 0.5f, 0.5f);
				return outPut;
			}

			fixed4 frag(v2f input) : SV_TARGET
			{
				return fixed4(input.color, 1.0f);
			}
			ENDCG
		}
	}
}