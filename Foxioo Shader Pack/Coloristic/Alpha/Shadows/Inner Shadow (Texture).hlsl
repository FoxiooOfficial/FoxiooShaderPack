/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (28.03.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

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
    float _PosX;
    float _PosY;
    float _Size;

    float4 _Color;
    float4 _ColorAccent;

    float _ColorAlpha;
    float _AlphaMul;
    float _AlphaBack;
    bool __;

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

static const int _Samples = 16;

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

    float _Alpha = 0.0;
    float _Idx = 0.0;

    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            
            _Alpha += S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Offset).a;
            _Idx += 1.0;
        }
    }
    
    _Alpha /= _Idx;

        float _InnerMask = _Render_Texture.a * (1.0 - _Alpha);
    
        _InnerMask = saturate(_InnerMask * _AlphaMul);

            float4 _OutlineColor = lerp(_ColorAccent, _Color, _InnerMask);
            _OutlineColor.a = _Render_Texture.a * _ColorAlpha;

        float4 _Render = _Render_Texture;
        _Render.a *= _AlphaBack;

        _Render = lerp(_Render, _OutlineColor, _InnerMask * _Mixing);

    Out.Color = _Render;
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

    float _Alpha = 0.0;
    float _Idx = 0.0;

    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            
            _Alpha += S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Offset).a;
            _Idx += 1.0;
        }
    }
    
    _Alpha /= _Idx;

        float _InnerMask = _Render_Texture.a * (1.0 - _Alpha);
    
        _InnerMask = saturate(_InnerMask * _AlphaMul);

            float4 _OutlineColor = lerp(_ColorAccent, _Color, _InnerMask);
            _OutlineColor.a = _Render_Texture.a * _ColorAlpha;

        float4 _Render = _Render_Texture;
        _Render.a *= _AlphaBack;

        _Render = lerp(_Render, _OutlineColor, _InnerMask * _Mixing);
        
    _Render.rgb *= _Render.a;
    Out.Color = _Render;
    return Out;
}