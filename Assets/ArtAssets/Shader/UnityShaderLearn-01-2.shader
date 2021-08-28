Shader "UnityShaderLearn/ShaderLearn-01-2"
{
	SubShader
    {
		Tags
		{
			"RenderType" = "MyTag3"
			"Nothing" = "A"
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
				return fixed4(0.5f, 0.4f, 0.8f, 1.0f);
			}
			ENDCG
		}
	}

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
				return fixed4(0.0f, 1.0f, 1.0f, 1.0f);
			}
			ENDCG
		}
	}
}