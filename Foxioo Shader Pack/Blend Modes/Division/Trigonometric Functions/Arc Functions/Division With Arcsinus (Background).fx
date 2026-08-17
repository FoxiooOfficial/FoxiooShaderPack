/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mul, _Mixing;
    
    int _Render_Switch;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define M_PI 3.14159265359

float3 Fun_Asin(float3 _Color, int _Case)
{   
    float3 _Render = asin(_Color);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9 simulated
    { 
        float a = -1.0 / M_PI * 1.07596f;
        float p = -M_PI;

        if(any(_Color < -1.0))
            return a * pow((_Color - p), 2.0f);

        else if(any(_Color > 1.0))
            return -a * pow((-_Color - p), 2.0f);

        else
            return _Render;
    }

    else if(_Case == 2) // D3D11, OGL simulated
    {
        float NaN = _Mixing < 0.0f ? 0x7FC00000 : 0.0f;

        float3 _Result;

            _Result.r = abs(_Color.r) > 1.0f ? NaN : _Render.r;
            _Result.g = abs(_Color.g) > 1.0f ? NaN : _Render.g;
            _Result.b = abs(_Color.b) > 1.0f ? NaN : _Render.b;
            //_Result.a = abs(_Color.a) > 1.0 ? NaN : _Render.a;

        return _Result;
    }

    else return float3(0.0f, 0.0f, 0.0f);
}

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result, _Render;

            if(!_Blending_Mode) { _Result.rgb = Fun_Asin(_Render_Texture.rgb / (_Render_Background.rgb * _Mul), _Render_Switch); _Render = _Render_Texture; }
            else                { _Result.rgb = Fun_Asin((_Render_Background.rgb * _Mul) / _Render_Texture.rgb, _Render_Switch); _Render = _Render_Background; } 
 
            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
                if(_Mixing == 0.0) _Result.rgb = _Render.rgb;

        _Result.a = _Render_Texture.a;
        
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
