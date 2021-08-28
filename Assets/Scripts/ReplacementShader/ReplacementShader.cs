using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ReplacementShader : MonoBehaviour
{
    public Button[] buttons;
    public Shader shader;
    // Start is called before the first frame update
    private void Awake()
    {
        buttons[0].onClick.AddListener(OnBtn0Clicked);
        buttons[1].onClick.AddListener(OnBtn1Clicked);
        buttons[2].onClick.AddListener(OnBtn2Clicked);
        buttons[3].onClick.AddListener(OnBtn3Clicked);
    }

    void OnBtn0Clicked() { OnBtnClicked(0); }
    void OnBtn1Clicked() { OnBtnClicked(1); }
    void OnBtn2Clicked() { OnBtnClicked(2); }
    void OnBtn3Clicked() { OnBtnClicked(3); }

    void OnBtnClicked(int index)
    {
        // 统一把想替换的shader叫做新shader
        switch (index)
        {
            case 0:
                // 直接替换新shader
                Camera.main.SetReplacementShader(shader, "");
                break;
            case 1:
                // 被替换的shader的第一个支持的SubShader没有这个标签 就不渲染
                // 被替换的shader的第一个支持的SubShader有这个标签 拿这个标签的值去新shader的每个subshader里去匹配
                Camera.main.SetReplacementShader(shader, "RenderType");
                break;
            case 2:
                // 新shader 的第一个支持的SubShader没有这个标签 就不渲染
                Camera.main.SetReplacementShader(shader, "Nothing");
                break;
            case 3:
                // 重置
                Camera.main.SetReplacementShader(null, "");
                break;
            default:
                break;
        }
    }
}
