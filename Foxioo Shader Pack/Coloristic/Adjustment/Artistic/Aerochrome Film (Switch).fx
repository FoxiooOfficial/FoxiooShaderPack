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
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

float3 RGBtoHSL(float3 _Render)
{
    float _CMax = max(_Render.r, max(_Render.g, _Render.b));
    float _CMin = min(_Render.r, min(_Render.g, _Render.b));
    float _Delta = _CMax - _CMin;

        float _H = 0.0;
        float _S = 0.0;
        float _L = (_CMax + _CMin) * 0.5;

    if (_Delta != 0.0)
    {
        _S = _Delta / (1.0 - abs(2.0 * _L - 1.0));

        if (_CMax == _Render.r) {
            _H = 60.0 * ((_Render.g - _Render.b) / _Delta);
        }
        else if (_CMax == _Render.g) {
            _H = 60.0 * ((_Render.b - _Render.r) / _Delta + 2.0);
        }
        else {
            _H = 60.0 * ((_Render.r - _Render.g) / _Delta + 4.0);
        }

        if (_H < 0.0) _H += 360.0;
    }
    
    return float3(_H, _S, _L);
}

float3 HSLtoRGB(float _H, float _S, float _L)
{
    float _C = (1.0 - abs(2.0 * _L - 1.0)) * _S;
    float _X = _C * (1.0 - abs((fmod(_H / 60.0, 2.0)) - 1.0));
    float _M = _L - _C * 0.5;
    
    float3 _Render =    (_H < 60.0)  ? float3(_C, _X,  0.0) :
                        (_H < 120.0) ? float3(_X, _C,  0.0) :
                        (_H < 180.0) ? float3(0.0, _C, _X)  :
                        (_H < 240.0) ? float3(0.0, _X, _C)  :
                        (_H < 300.0) ? float3(_X,  0.0, _C) :
                        float3(_C, 0, _X);
    
    return (_Render + _M);
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

        const float _HueTarget      = 120.0;
        const float _HueSize        = 90.0;
        const float _SaturationMin  = 0.15;
        const float _HueEnd         = 357.0;
        const float _HueEndAdd      = 0.25;
        const float _HueEndLift     = 0.05;

            float3 _Fixed   = float3(0.0, 0.3, 0.0) * Fun_Luminance(_Render.rgb);
            float3 _HSL     = RGBtoHSL(saturate(_Render.rgb + _Fixed));
            float3 _HSLEnd  = _HSL;

                float _Diff = abs(_HSLEnd.x - _HueTarget);
                _Diff = (_Diff > 180.0) ? 360.0 - _Diff : _Diff;

                float3 _Mask;
                _Mask.x = smoothstep(0.0, 1.0, (1.0 - (_Diff / _HueSize)));
                _Mask.y = smoothstep(_SaturationMin, _SaturationMin + 0.25, _Mask.x);

            float3 _Sum = saturate(_Render.rgb + _Fixed);
            float _DiffEx = ((_Sum.g - max(_Sum.r, _Sum.b)) * 3.0);
            _Mask.z = _Mask.x * _Mask.y * _DiffEx;

                float3 _HueOut;
                _HueOut.x = _HueEnd;
                _HueOut.y = saturate(_HSLEnd.y + _HueEndAdd);
                _HueOut.z = saturate(_HSLEnd.z + _HueEndLift);

            float3 _RenderHue = HSLtoRGB(_HueOut.x, _HueOut.y, _HueOut.z);

                _RenderHue.rb *= 1.2;
                _RenderHue.g *= 0.8;

            _Result.rgb = lerp(_Render.rgb, _RenderHue, saturate(_Mask.z * _Mixing));
            
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
