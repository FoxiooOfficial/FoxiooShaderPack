/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/* Special thanks to The Cherno.
    The video from which I took help on how to do this effect: https://www.youtube.com/watch?v=tI70-HIc5ro */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = CLAMP;
    AddressV = CLAMP;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    AddressU = CLAMP;
    AddressV = CLAMP;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,

            _BlurStrength, _BloomIntensity, _BloomAddition,

            _ResB, _ResF,

            fPixelWidth, fPixelHeight;

/***********************************************************/
/* Main */
/***********************************************************/

float4 Fun_Blur(float2 UV)
{
    float4 _Result = tex2D(S2D_Image, UV);
    
    _Result += tex2D(S2D_Image, UV + float2(_BlurStrength * fPixelWidth, 0));
    _Result += tex2D(S2D_Image, UV - float2(_BlurStrength * fPixelWidth, 0));
    _Result += tex2D(S2D_Image, UV + float2(0, _BlurStrength * fPixelHeight));
    _Result += tex2D(S2D_Image, UV - float2(0, _BlurStrength * fPixelHeight));

    return _Result / 5.0;
}


float4 Fun_ReScale(float2 In, float _ScaleFactor)
{
    _ScaleFactor = 1.0 / _ScaleFactor;
    
    float2 _Res = float2(fPixelWidth, fPixelHeight);
    float2 _BlockSize = _ScaleFactor * _Res;
    
        float2 _UV = floor(In / _BlockSize) * _BlockSize;
        float2 _InFrac = frac(In / _BlockSize);
    
            //float4 _Render_A = tex2D(S2D_Image, _UV);
            //float4 _Render_B = tex2D(S2D_Image, _UV + float2(_BlockSize.x, 0));
            //float4 _Render_C = tex2D(S2D_Image, _UV + float2(0, _BlockSize.y));
            //float4 _Render_D = tex2D(S2D_Image, _UV + _BlockSize);

            float4 _Render_A = Fun_Blur(_UV);
            float4 _Render_B = Fun_Blur(_UV + float2(_BlockSize.x, 0));
            float4 _Render_C = Fun_Blur(_UV + float2(0, _BlockSize.y));
            float4 _Render_D = Fun_Blur(_UV + _BlockSize);
    
                float4 _RenderTop = lerp(_Render_A, _Render_B, _InFrac.x);
                float4 _RenderBottom = lerp(_Render_C, _Render_D, _InFrac.x);
    
        float4 _Result = lerp(_RenderTop, _RenderBottom, _InFrac.y);
    
    return _Result;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    
        float4 _Result = _Render_Texture;
        _Result *= _Result;

               // Resolution 50%
                _Result += Fun_ReScale(In, 0.5) * _ResB;

                // Resolution 25%
                _Result += Fun_ReScale(In, 0.0625) * _ResF;

                // Resolution 12.5%
                //_Result += Fun_ReScale(In, 0.0625);

                // Resolution 6.25%
                //_Result += Fun_ReScale(In, 0.015625);

            _Result /= 3.0;

    float4 _Bloom = Fun_Blur(In);
        _Result += _Bloom * _BloomIntensity;

    _Result = _Render_Texture + _Result * _BloomAddition;
    _Result.rgb += lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, 1.0 - normalize(_Result.a)) * _Mixing;

    return _Result;
}

/***********************************************************/
/* Technique */
/***********************************************************/
technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
