/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/* Special thanks to The Cherno.
    The video from which I took help on how to do this effect: https://www.youtube.com/watch?v=tI70-HIc5ro */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    bool __;
    float _BloomAddition;
    float _BlurStrength;
    float _BloomIntensity;
    bool ___;
    float _ResA;
    float _ResB;
    float _ResC;
    float _ResD;
    float _ResE;
    float _ResF;
    float _ResG;
    bool ____;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
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

static const float _Kernel[7] = { 
    0.079589, 0.120651, 0.146768, 0.159155, 0.146768, 0.120651, 0.079589
};

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Blur(float2 UV)
{
    float4 _Result = S2D_Image.Sample(S2D_ImageSampler, UV);

    for (int i = 1; i < 7; i++)
    {
        float2 _Offset = float2(fPixelWidth * i * _BlurStrength, 0);
        _Result += S2D_Image.Sample(S2D_ImageSampler, UV + _Offset) * _Kernel[i];
        _Result += S2D_Image.Sample(S2D_ImageSampler, UV - _Offset) * _Kernel[i];
    }

    for (int j = 1; j < 7; j++)
    {
        float2 _Offset = float2(0, fPixelHeight * j * _BlurStrength);
        _Result += S2D_Image.Sample(S2D_ImageSampler, UV + _Offset) * _Kernel[j];
        _Result += S2D_Image.Sample(S2D_ImageSampler, UV - _Offset) * _Kernel[j];
    }

    return _Result / 15.0;
}

float4 Fun_ReScale(float2 In, float _ScaleFactor)
{
    _ScaleFactor = 1.0 / _ScaleFactor;
    
    float2 _Res = float2(fPixelWidth, fPixelHeight);
    float2 _BlockSize = _ScaleFactor * _Res;
    
        float2 _UV = floor(In / _BlockSize) * _BlockSize;
        float2 _InFrac = frac(In / _BlockSize);
    
            //float4 _Render_A = S2D_Image.Sample(S2D_ImageSampler, _UV);
            //float4 _Render_B = S2D_Image.Sample(S2D_ImageSampler, _UV + float2(_BlockSize.x, 0));
            //float4 _Render_C = S2D_Image.Sample(S2D_ImageSampler, _UV + float2(0, _BlockSize.y));
            //float4 _Render_D = S2D_Image.Sample(S2D_ImageSampler, _UV + _BlockSize);

            float4 _Render_A = Fun_Blur(_UV);
            float4 _Render_B = Fun_Blur(_UV + float2(_BlockSize.x, 0));
            float4 _Render_C = Fun_Blur(_UV + float2(0, _BlockSize.y));
            float4 _Render_D = Fun_Blur(_UV + _BlockSize);
    
                float4 _RenderTop = lerp(_Render_A, _Render_B, _InFrac.x);
                float4 _RenderBottom = lerp(_Render_C, _Render_D, _InFrac.x);
    
        float4 _Result = lerp(_RenderTop, _RenderBottom, _InFrac.y);
    
    return _Result;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Render_Texture;
        _Result *= _Result;

                //Resulution 75%
                _Result += Fun_ReScale(In.texCoord, 0.75) * _ResA;

               // **** Resolution 50%
                    _Result += Fun_ReScale(In.texCoord, 0.5) * _ResB;

                //Resulution 37.5%
                _Result += Fun_ReScale(In.texCoord, 0.375) * _ResC;

                // Resolution 25%
                    _Result += Fun_ReScale(In.texCoord, 0.25) * _ResD;

                // Resolution 12.5%
                    _Result += Fun_ReScale(In.texCoord, 0.125) * _ResE;

                // Resolution 6.25%
                    _Result += Fun_ReScale(In.texCoord, 0.0625) * _ResF;

                // Resolution 3.125%
                _Result += Fun_ReScale(In.texCoord, 0.03125) * _ResG;

            _Result /= 7.0;

    float4 _Bloom = Fun_Blur(In.texCoord);
        _Result += _Bloom * _BloomIntensity;

    _Result = _Render_Texture + _Result * _BloomAddition;
    _Result.rgb += lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, 1.0 - normalize(_Result.a)) * _Mixing;

    //_Result.a = _Render_Texture.a;
    Out.Color = _Result;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

float4 Fun_Blur_Demultiply(float2 UV)
{
    float4 _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV));

    for (int i = 1; i < 7; i++)
    {
        float2 _Offset = float2(fPixelWidth * i * _BlurStrength, 0);
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV + _Offset)) * _Kernel[i];
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV - _Offset)) * _Kernel[i];
    }

    for (int j = 1; j < 7; j++)
    {
        float2 _Offset = float2(0, fPixelHeight * j * _BlurStrength);
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV + _Offset)) * _Kernel[j];
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV - _Offset)) * _Kernel[j];
    }

    return _Result / 15.0;
}

float4 Fun_ReScale_Demultiply(float2 In, float _ScaleFactor)
{
    _ScaleFactor = 1.0 / _ScaleFactor;
    
    float2 _Res = float2(fPixelWidth, fPixelHeight);
    float2 _BlockSize = _ScaleFactor * _Res;
    
        float2 _UV = floor(In / _BlockSize) * _BlockSize;
        float2 _InFrac = frac(In / _BlockSize);
    
            //float4 _Render_A = S2D_Image.Sample(S2D_ImageSampler, _UV);
            //float4 _Render_B = S2D_Image.Sample(S2D_ImageSampler, _UV + float2(_BlockSize.x, 0));
            //float4 _Render_C = S2D_Image.Sample(S2D_ImageSampler, _UV + float2(0, _BlockSize.y));
            //float4 _Render_D = S2D_Image.Sample(S2D_ImageSampler, _UV + _BlockSize);

            float4 _Render_A = Fun_Blur_Demultiply(_UV);
            float4 _Render_B = Fun_Blur_Demultiply(_UV + float2(_BlockSize.x, 0));
            float4 _Render_C = Fun_Blur_Demultiply(_UV + float2(0, _BlockSize.y));
            float4 _Render_D = Fun_Blur_Demultiply(_UV + _BlockSize);
    
                float4 _RenderTop = lerp(_Render_A, _Render_B, _InFrac.x);
                float4 _RenderBottom = lerp(_Render_C, _Render_D, _InFrac.x);
    
        float4 _Result = lerp(_RenderTop, _RenderBottom, _InFrac.y);
    
    return _Result;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Render_Texture;
        _Result *= _Result;

                //Resulution 75%
                _Result += Fun_ReScale_Demultiply(In.texCoord, 0.75) * _ResA;

               // **** Resolution 50%
                    _Result += Fun_ReScale_Demultiply(In.texCoord, 0.5) * _ResB;

                //Resulution 37.5%
                _Result += Fun_ReScale_Demultiply(In.texCoord, 0.375) * _ResC;

                // Resolution 25%
                    _Result += Fun_ReScale_Demultiply(In.texCoord, 0.25) * _ResD;

                // Resolution 12.5%
                    _Result += Fun_ReScale_Demultiply(In.texCoord, 0.125) * _ResE;

                // Resolution 6.25%
                    _Result += Fun_ReScale_Demultiply(In.texCoord, 0.0625) * _ResF;

                // Resolution 3.125%
                _Result += Fun_ReScale_Demultiply(In.texCoord, 0.03125) * _ResG;

            _Result /= 7.0;

    float4 _Bloom = Fun_Blur_Demultiply(In.texCoord);
        _Result += _Bloom * _BloomIntensity;

    _Result = _Render_Texture + _Result * _BloomAddition;
    _Result.rgb += lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, 1.0 - normalize(_Result.a)) * _Mixing;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}