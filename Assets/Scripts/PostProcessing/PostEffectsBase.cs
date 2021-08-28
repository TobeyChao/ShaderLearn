using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    private void Start()
    {
        CheckResources();
    }

    protected void CheckResources()
    {
        bool isSupport = CheckSupport();
        if (!isSupport)
        {
            NotSupported();
        }
    }

    private void NotSupported()
    {
        enabled = false;
    }

    private bool CheckSupport()
    {
        if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
        {
            Debug.LogWarning("Post Effects Not Supported!");
            return false;
        }
        return true;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }
        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }
        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
        }
    }
}
