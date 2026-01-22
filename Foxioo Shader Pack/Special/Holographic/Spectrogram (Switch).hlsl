/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (20.10.2026) */
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
    float _Time;
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

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b); }

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }

        const float3 _Color0 = float3(1.0, 1.0, 1.0); // Whi
        const float3 _Color1 = float3(1.0, 1.0, 0.0); // Yel
        const float3 _Color2 = float3(1.0, 0.0, 0.0); // Red
        const float3 _Color3 = float3(0.5, 0.0, 0.5); // Pur
        const float3 _Color4 = float3(0.0, 0.0, 0.25); // Blu
        const float3 _Color5 = float3(0.0, 0.0, 0.0); // Blk

            //_Result.rgb = pow(_Result.rgb, 2.2); 
            float _Lum = Fun_Lum(_Result);

            if(!_Blending_Mode) _Result = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(_Lum * sin(_Lum + In.texCoord.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.texCoord.y * 400.0 * _Mixing + sin(In.texCoord.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing)) * In.Tint;
            else                _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(_Lum * sin(_Lum + In.texCoord.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.texCoord.y * 400.0 * _Mixing + sin(In.texCoord.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing));
            
                _Lum = Fun_Lum(_Result);
                if (_Lum < 0.2)         _Result.rgb = lerp(_Color5, _Color4, _Lum / 0.2);
                else if (_Lum < 0.4)    _Result.rgb = lerp(_Color4, _Color3, (_Lum - 0.2) / 0.2);
                else if (_Lum < 0.6)    _Result.rgb = lerp(_Color3, _Color2, (_Lum - 0.4) / 0.2);
                else if (_Lum < 0.8)    _Result.rgb = lerp(_Color2, _Color1, (_Lum - 0.6) / 0.2);
                else                    _Result.rgb = lerp(_Color1, _Color0, (_Lum - 0.8) / 0.2);
                _Result = lerp(_Render, _Result, _Mixing);

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

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }
    
        const float3 _Color0 = float3(1.0, 1.0, 1.0); // Whi
        const float3 _Color1 = float3(1.0, 1.0, 0.0); // Yel
        const float3 _Color2 = float3(1.0, 0.0, 0.0); // Red
        const float3 _Color3 = float3(0.5, 0.0, 0.5); // Pur
        const float3 _Color4 = float3(0.0, 0.0, 0.25); // Blu
        const float3 _Color5 = float3(0.0, 0.0, 0.0); // Blk

            //_Result.rgb = pow(_Result.rgb, 2.2); 
            float _Lum = Fun_Lum(_Result);

            if(!_Blending_Mode) _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(_Lum * sin(_Lum + In.texCoord.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.texCoord.y * 400.0 * _Mixing + sin(In.texCoord.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing))) * In.Tint;
            else                _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(_Lum * sin(_Lum + In.texCoord.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.texCoord.y * 400.0 * _Mixing + sin(In.texCoord.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing));
            
                _Lum = Fun_Lum(_Result);
                if (_Lum < 0.2)         _Result.rgb = lerp(_Color5, _Color4, _Lum / 0.2);
                else if (_Lum < 0.4)    _Result.rgb = lerp(_Color4, _Color3, (_Lum - 0.2) / 0.2);
                else if (_Lum < 0.6)    _Result.rgb = lerp(_Color3, _Color2, (_Lum - 0.4) / 0.2);
                else if (_Lum < 0.8)    _Result.rgb = lerp(_Color2, _Color1, (_Lum - 0.6) / 0.2);
                else                    _Result.rgb = lerp(_Color1, _Color0, (_Lum - 0.8) / 0.2);
                _Result = lerp(_Render, _Result, _Mixing);

        _Result = lerp(_Render, _Result, _Mixing);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;
    Out.Color = _Result;
    return Out;  
}
