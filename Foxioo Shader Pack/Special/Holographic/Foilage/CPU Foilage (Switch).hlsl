/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _RotX;
    bool ____;
    float _PointX;
    float _PointY;
    bool _____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ______;
    bool _Blending_Mode;
    float _Mixing;
    int _ChannelRed;
    int _ChannelGreen;
    int _ChannelBlue;
    bool _______;

	bool _Is_Pre_296_Build;
	bool ________;
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

float2 Fun_RotationX(float2 In)
{
    float2  _UV = float2((In.x + _PointX) / 2.0, (In.y + _PointY) / 2.0);
    float _RotXTemp = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotXTemp), sin(_RotXTemp), -sin(_RotXTemp), cos(_RotXTemp)), _UV);

    return _UV;
}

float3 Fun_Rainbow(float2 In)
{
    static const float _Frag = 6.28318;
    float3 _Render;
    
    float _Red, _Green, _Blue;
    if(_ChannelRed == 0) _Red = In.x;       else if (_ChannelRed == 1) _Red = In.y;         else  _Red = In.x + In.y;
    if(_ChannelGreen == 0) _Green = In.x;   else if (_ChannelGreen == 1) _Green = In.y;     else  _Green = In.x + In.y;
    if(_ChannelBlue == 0) _Blue = In.x;     else if (_ChannelBlue == 1) _Blue = In.y;       else  _Blue = In.x + In.y;
    
    _Render.r = sin(_Frag * _Red + 0.0) * 0.5 + 0.5;
    _Render.g = sin(_Frag * _Green + 2.0) * 0.5 + 0.5;
    _Render.b = sin(_Frag * _Blue + 4.0) * 0.5 + 0.5;

    return _Render;
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Result;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

        _Result.a = _Render_Texture.a;

            float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

            float2  _UV = Fun_RotationX(In.texCoord * _Average),
                    _ScaleTemp = (float2(_ScaleX, _ScaleY)) * _Scale,
                    _Pos = float2(-_PosX, _PosY);


            float3 _Render_Rainbow = Fun_Rainbow((_UV - _Pos) * _ScaleTemp);

        _Result.rgb += _Render_Rainbow.rgb * _Average * _Mixing;

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

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

        _Result.a = _Render_Texture.a;

            float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

            float2  _UV = Fun_RotationX(In.texCoord * _Average),
                    _ScaleTemp = (float2(_ScaleX, _ScaleY)) * _Scale,
                    _Pos = float2(-_PosX, _PosY);


            float3 _Render_Rainbow = Fun_Rainbow((_UV - _Pos) * _ScaleTemp);

        _Result.rgb += _Render_Rainbow.rgb * _Average * _Mixing;

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
