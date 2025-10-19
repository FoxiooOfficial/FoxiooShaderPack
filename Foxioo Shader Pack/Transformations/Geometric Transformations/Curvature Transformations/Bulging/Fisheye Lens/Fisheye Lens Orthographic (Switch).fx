/***********************************************************/

/* Autor shader: Foxioo */
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
/* Varibles */
/***********************************************************/

    float   _Mixing,
            
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,
            _RotX,
            _PosOffsetX, _PosOffsetY,
            _PointX, _PointY,
            _Distortion;

    int     _Looping_Mode;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_FishEye(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _In = In - _Points;

    float _Ray = length(_In);
    float _Theta = atan2(_In.y, _In.x);

        float _Mode_Orthographic = sin(_Ray) * (1.0 + _Distortion);

    float2 _UV = float2(cos(_Theta), sin(_Theta)) * _Mode_Orthographic;

        float2 _Result = lerp(In, _UV + _Points, _Mixing);
        return _Result;
}


float2 Fun_RotationX(float2 In: TEXCOORD)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In - _Points;
    _RotX = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotX), sin(_RotX), -sin(_RotX), cos(_RotX)), _UV);

    return _UV + _Points;

}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

    float2  _Pos = float2(_PosX, _PosY),
            _UV = Fun_RotationX(Fun_FishEye(In + _Pos));
            _UV = ((_UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

    if(_Looping_Mode == 0)
    {
        _UV = frac(_UV);
    }
    else if(_Looping_Mode == 1)
    {
        _UV /= 2;
        _UV = frac(_UV);
        _UV = abs(_UV * 2.0 - 1.0);
    }

    float4 _Render_Texture_UV = tex2D(S2D_Image, _UV);
    float4 _Render_Background_UV = tex2D(S2D_Background, _UV);

    float4 _Result = _Blending_Mode ? _Render_Background_UV : _Render_Texture_UV;

        if (_Looping_Mode == 3 && (_UV.x < 0 || _UV.x > 1 || _UV.y < 0 || _UV.y > 1))
        {
            _Result = 0;
        }

    _Result.a *= _Render_Texture_UV.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
