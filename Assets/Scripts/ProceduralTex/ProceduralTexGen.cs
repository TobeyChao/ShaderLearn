using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTexGen : MonoBehaviour
{
    public Material m_Material = null;
    #region Material Properties
    [SerializeField, SetProperty("TextureWidth")]
    private int m_TextureWidth;
    public int TextureWidth
    {
        get
        {
            return m_TextureWidth;
        }
        set
        {
            m_TextureWidth = value;
            UpdateMaterial();
        }
    }
    [SerializeField, SetProperty("BackgroundColor")]
    private Color m_BackgroundColor;
    public Color BackgroundColor
    {
        get
        {
            return m_BackgroundColor;
        }
        set
        {
            m_BackgroundColor = value;
            UpdateMaterial();
        }
    }
    [SerializeField, SetProperty("CircleColor")]
    private Color m_CircleColor;
    public Color CircleColor
    {
        get
        {
            return m_CircleColor;
        }
        set
        {
            m_CircleColor = value;
            UpdateMaterial();
        }
    }
    [SerializeField, SetProperty("BlurFactor")]
    private float m_BlurFactor;
    public float BlurFactor
    {
        get
        {
            return m_BlurFactor;
        }
        set
        {
            m_BlurFactor = value;
            UpdateMaterial();
        }
    }
    #endregion
    private Texture2D m_GenerateTexture = null;
    private void UpdateMaterial()
    {
        if (m_Material != null)
        {
            m_GenerateTexture = GenerateProceduralTexture();
            m_Material.SetTexture("_MainTex", m_GenerateTexture);
        }
    }
    private Color MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    private Texture2D GenerateProceduralTexture()
    {
        Texture2D texture2D = new Texture2D(m_TextureWidth, m_TextureWidth);
        float circleInterval = m_TextureWidth * 0.25f;
        float radius = m_TextureWidth * 0.125f;
        float edgeBlur = 1.0f / m_BlurFactor;
        for (int i = 0; i < m_TextureWidth; i++)
        {
            for (int j = 0; j < m_TextureWidth; j++)
            {
                Color pixel = m_BackgroundColor;

                for (int m = 0; m < 3; m++)
                {
                    for (int n = 0; n < 3; n++)
                    {
                        Vector2 center = new Vector2(circleInterval * (m + 1), circleInterval * (n + 1));
                        float dist = Vector2.Distance(new Vector2(i, j), center) - radius;
                        Color color = MixColor(m_CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0.0f, 1.0f, dist * edgeBlur));
                        pixel = MixColor(pixel, color, color.a);
                    }
                }

                texture2D.SetPixel(i, j, pixel);
            }
        }
        texture2D.Apply();
        return texture2D;
    }

    public void Start()
    {
        if (m_Material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Renderer Not Found!");
            }
            m_Material = renderer.sharedMaterial;
        }
        UpdateMaterial();
    }
}