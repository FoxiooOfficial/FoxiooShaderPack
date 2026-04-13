/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (12.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

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
    bool _Blending_Mode;
    float _Mixing;
    float _DitheringSize; 
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
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

/************************************************************/
/* Main */
/************************************************************/

float Fun_Quant(float _Color)
{
    return floor(_Color * 3.0 + 0.5) / 3.0;
}

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

float3 Fun_Convert(float3 _Color)
{
    return float3(Fun_Quant(_Color.r), Fun_Quant(_Color.g), Fun_Quant(_Color.b));
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }

            int2 _Dith = int2(  fmod(In.texCoord.x / fPixelWidth, 4.0), 
                                fmod(In.texCoord.y / fPixelHeight, 4.0)
                            );

                int _Index = _Dith.x + _Dith.y * 4;
                float _DithValue = _Dithering[_Index];
                
                    float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                    _Color = saturate(_Color);

            _Result.rgb = Fun_Convert(_Color);

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);  

    _Result.a = _Render_Texture.a;
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

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }

            int2 _Dith = int2(  fmod(In.texCoord.x / fPixelWidth, 4.0), 
                                fmod(In.texCoord.y / fPixelHeight, 4.0)
                            );

                int _Index = _Dith.x + _Dith.y * 4;
                float _DithValue = _Dithering[_Index];
                
                    float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                    _Color = saturate(_Color);

            _Result.rgb = Fun_Convert(_Color);
            
            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 

    _Result.a = _Render_Texture.a;
    
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
