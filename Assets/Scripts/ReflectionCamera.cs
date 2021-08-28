using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReflectionCamera : MonoBehaviour
{
    public Cubemap cubemap;
    public Camera reflectionCamera;
    bool isDirty = false;
    void Start()
    {
        reflectionCamera.RenderToCubemap(cubemap);
    }

    //void Update()
    //{
    //    if (isDirty)
    //    {
    //        reflectionCamera.RenderToCubemap(cubemap);
    //    }
    //}
}
