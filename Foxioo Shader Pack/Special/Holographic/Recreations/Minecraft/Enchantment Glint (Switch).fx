/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/************************************************************/

/*  Special thanks to Daniel Ilett.

    The video from which I took help on how to do this effect: https://www.youtube.com/watch?v=iRegHo8_GBk */

/************************************************************/

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
            _PointX, _PointY,
            _RotX,
            _ScaleX, _ScaleY, _Scale,
            
            _Intensity;

    bool    _Blending_Mode;

    float4  _Color;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In: TEXCOORD)
{
    float2  _UV = float2((In.x - (_PointX + 0.5)) / 2.0, (In.y - (_PointY + 0.5)) / 2.0);
    _RotX = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotX), sin(_RotX), -sin(_RotX), cos(_RotX)), _UV);

    return _UV;
}


float Fun_CalculateGlint(float2 In, float _OffsetX, float _OffsetY, float _Scale, float _Intensity)
{
    return pow(1 - frac((sin((In.x - _OffsetX) * _Scale) / 2.0 + 0.5) * (cos((In.y + _OffsetY) * _Scale) / 2.0 + 0.5)), _Intensity);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    In = Fun_RotationX(In);
    float2 _UV = float2((In.x + _PosX) * _ScaleX, (In.y + _PosY) * _ScaleY) * _Scale;

    //float2 _UV_Glint = (1 - frac((sin(_UV.x) / 2.0 + 0.5) * (cos(_UV.y) / 2.0 + 0.5)));

    float _UV_Glint_1 = Fun_CalculateGlint(_UV, 0.3, 0.6, 0.75, _Intensity);
    float _UV_Glint_2 = Fun_CalculateGlint(_UV, 0.5, 1.5, 0.5, _Intensity);
    float _UV_Glint_3 = Fun_CalculateGlint(_UV, 0.66, -1.3, 0.25, _Intensity);

    float _UV_Glint_Sum = (_UV_Glint_1 + _UV_Glint_2 + _UV_Glint_3) / 3.0;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

        _Result.a = _Render_Texture.a;

        _Result.rgb += _Color.rgb * _UV_Glint_Sum * _Mixing * _Result.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
