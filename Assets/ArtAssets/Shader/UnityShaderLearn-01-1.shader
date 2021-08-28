Shader "UnityShaderLearn/ShaderLearn-01-1"
{
	SubShader
    {
		Tags
		{
			"RenderType" = "MyTag2"
		}
		pass
        {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float4 vert(float4 v : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(v);
			}
			fixed4 frag() : SV_TARGET
			{
				return fixed4(0.0f, 1.0f, 0.0f, 1.0f);
			}
			ENDCG
		}
	}

	SubShader
    {
		Tags
		{
			"RenderType" = "MyTag1"
		}
		pass
        {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float4 vert(float4 v : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(v);
			}
			fixed4 frag() : SV_TARGET
			{
				return fixed4(1.0f, 0.0f, 0.0f, 1.0f);
			}
			ENDCG
		}
	}

}