using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader m_Shader;
    private Material m_Material;
    [Range(0.0f, 3.0f)]
    public float m_Brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float m_Saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float m_Contrast = 1.0f;

    public Material Material
    {
        get
        {
            m_Material = CheckShaderAndCreateMaterial(m_Shader, m_Material);
            return m_Material;
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            Material.SetFloat("_Brightness", m_Brightness);
            Material.SetFloat("_Saturation", m_Saturation);
            Material.SetFloat("_Contrast", m_Contrast);
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
