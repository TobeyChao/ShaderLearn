Shader "UnityShaderLearn/ShaderLearn-01"
{
	SubShader
    {
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
}