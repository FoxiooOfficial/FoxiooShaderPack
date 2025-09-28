/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (29.08.2025) */
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

float2 Fun_Bulge(float2 In)
{
    float2 _Center = float2(_PointX, _PointY);
    float2 _Rel = In - _Center;
    float _Ray = length(_Rel);

    float _Distance = _Ray * _Distortion;
    float2 _UV = _Rel * _Distance;

    In = lerp(_Rel, _UV, _Mixing) + _Center;

    return In;
}

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Temp = _RotX * (3.14159265 / 180);

        _UV = _Points + mul(float2x2(cos(_RotX_Temp), sin(_RotX_Temp), -sin(_RotX_Temp), cos(_RotX_Temp)), _UV - _Points);

    return _UV;

}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float2  _Pos = float2(_PosX, _PosY),
        _UV = Fun_RotationX((In + _Pos));
        _UV = ((_UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);
         
    _UV = Fun_Bulge(_UV);

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

        if (_Looping_Mode == 3 && any(_UV < 0 || _UV > 1))
        {
            _Result = 0;
        }

    _Result.a *= _Render_Texture_UV.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
