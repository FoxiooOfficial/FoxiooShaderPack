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

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Angle;
    float _Size;
    float _Jump;
    float _Strength;
    float _Threshold;
    float _Fade;
    int _Loop;
    float4 _Color;
    float4 _ColorIgnore;
    float _OffsetX;
    float _OffsetY;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

//static int _MaxSteps = 256;

bool Fun_Comp(float3 _Color)
{
    if (all(_ColorIgnore.rgb == 0.0))
        return false;

    return all(abs(_Color.rgb - _ColorIgnore.rgb) <= 0.01);
}

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);

    if(Fun_Comp(_Render_Texture.rgb))
        return 0.0;
    
    if (_Render_Texture.a >= 1.0)
        return _Render_Texture;

    /* Screenspace Reflection! */
        float _Rad = _Angle * 0.0174532925199444; // (3.14159265359 / 180.0);

        float2 _SinCos;
        sincos(_Rad, _SinCos.x, _SinCos.y);

        float2 _Ray = _SinCos * float2(fPixelWidth, fPixelHeight) * _Size;
        float2 UV = In.texCoord + float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);

            float4 _Render_Reflection = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint, _Premultiplied);
            float2 _Hit = 0.0;

    /* raymarching */
    int _Steps = clamp(_Loop, 0, 1024);

    [loop]
    for (int i = 1; i <= _Steps; i++)
    {
        UV += _Ray * (64.0 / (float)_Loop);

        if (any(UV <= 0.0 || UV >= 1.0)) 
            break;

        float4 _Render_Reflected = Demultiply(S2D_Image.SampleLevel(S2D_ImageSampler, UV, 0) * In.Tint, _Premultiplied);

        if (Fun_Comp(_Render_Reflected.rgb))
            continue;
            
        if (_Render_Reflected.a > _Threshold)
        {        
            float2 UV_Ref = In.texCoord + (_Ray * float(i * (64.0 / (float)_Loop)) * _Jump);
            float4 _Render = Demultiply(S2D_Image.SampleLevel(S2D_ImageSampler, UV_Ref, 0) * In.Tint, _Premultiplied);
                    
            if (any(UV_Ref <= 0.0 || UV_Ref >= 1.0) || Fun_Comp(_Render.rgb)) 
                break;

            _Render.rgb *= _Color.rgb;

                if(_Render.a == 0.0)
                    break;
                
                if (_Render.a > _Threshold) 
                {
                    _Render_Reflection = _Render;
                    _Hit = float2((float(i) * 2.0) / float(_Steps), 1.0); 
                }
            
            break;
        }
    }

    /* fade :3 */
    if (bool(_Hit.y))
    {
        float _InvertedFade = 1.0 - _Hit.x; 
        if(_InvertedFade <= 0.0)
            return 0.0; 

        _InvertedFade = saturate(pow(abs(_InvertedFade * _InvertedFade), _Fade));

        float _Alpha = _Strength * _InvertedFade * _Render_Reflection.a;
        
        float4 _Render;
        _Render.rgb = lerp(_Render_Texture.rgb, _Render_Reflection.rgb, _Alpha);
        _Render.a = max(_Render_Texture.a, _Alpha); 

        _Render = lerp(_Render_Texture, _Render, _Mixing);

        return _Render;
    }
    else
        return _Render_Reflection;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
