/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.4 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float _Mixing, _Mul;
    int _Render_Switch;
    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define M_PI 3.14159265359

float4 Fun_Asin(float4 _Color, int _Case)
{   
    float4 _Render = asin(_Color);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9
    { 

        float a = -1.0 / M_PI * 1.07596;
        float p = -M_PI;

        if(any(_Color < -1.0))
            return a * pow((_Color - p), 2.0);

        else if(any(_Color > 1.0))
            return -a * pow((-_Color - p), 2.0);

        else
            return _Render;
    }

    else if(_Case == 2) // D3D11, OGL
    { 
        return (any(abs(_Render > 1.0))) ? _Color <= 1.0f : _Render;

    }

    else return float4(0.0f, 0.0f, 0.0f, 0.0f);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == false)
        {
            _Result = Fun_Asin(_Render_Texture * _Mul, _Render_Switch);
            _Render = _Render_Texture;
        }
        else
        {
            _Result = Fun_Asin(_Render_Background * _Mul, _Render_Switch);
            _Render = _Render_Background;
        }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
