/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = Point;
    AddressU = Wrap;
    AddressV = Wrap;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosX, _PosY,
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,
            _Mixing,
            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In, float _RotExtra, float _Scaler)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Fix = (_RotX + _RotExtra) * (3.14159265 / 180.0) / _Scaler;

        _UV = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}

float2 Fun_UV(float _UVRot, float2 _UVPos, float _UVScaler, float2 UV)
{
    UV = Fun_RotationX(UV, _UVRot, _UVScaler) + _UVPos / _UVScaler;
    UV = (UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale + float2(_PointX, _PointY);
    return frac(UV * _UVScaler);
}

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float2 _Pos = float2(_PosX, _PosY);
        float4 _Result = 0;

        float4 _Render = tex2D(S2D_Image, Fun_UV(236, _Pos, 3, In));
        float _Lum = _Render.r * _Render.g * _Render.b * _Render.a;
        _Result += lerp(_Render, _Render_Texture, _Lum);

        _Result += tex2D(S2D_Image, Fun_UV(206, _Pos, 2, In));
        _Result += tex2D(S2D_Image, Fun_UV(127, _Pos, 1, In));
        _Result += tex2D(S2D_Image, Fun_UV(2, _Pos, 0.5, In));

        _Result /= 3.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }