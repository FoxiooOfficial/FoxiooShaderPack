/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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

    float   _Mixing,
            _PosX, _PosY,
            _PointX, _PointY,
            _RotX,
            _ScaleX, _ScaleY, _Scale;

    bool    _Blending_Mode;

    int     _ChannelRed, _ChannelGreen, _ChannelBlue;

/***********************************************************/
/* Main */
/***********************************************************/

float2 Fun_RotationX(float2 In)
{
    float2  _UV = float2((In.x + _PointX) / 2.0, (In.y + _PointY) / 2.0);
    _RotX = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotX), sin(_RotX), -sin(_RotX), cos(_RotX)), _UV);

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

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

        float2  _UV = Fun_RotationX(In * _Average),
                _ScaleTemp = (float2(_ScaleX, _ScaleY)) * _Scale,
                _Pos = float2(-_PosX, _PosY);


        float3 _Render_Rainbow = Fun_Rainbow((_UV - _Pos) * _ScaleTemp);

    _Result.rgb += _Render_Rainbow.rgb * _Average * _Mixing;

    return _Result;
}

/***********************************************************/
/* Tech Main */
/***********************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
