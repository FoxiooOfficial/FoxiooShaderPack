/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (30.06.2024) */
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
};

sampler2D S2D_Background : register(s1) = sampler_state 
{
    MinFilter = Point;
    MagFilter = Point;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosX, _PosY, _PosZ,
            _OffsetX,
            _ScaleX, _ScaleY, _Scale,
            _RotX, _RotY, _RotZ,
            _Distortion,
            _PointX, _PointY;

    int     _Looping_Mode, _Filter_Mode;

    bool    _Render_Sky, _Result;

/***********************************************************/
/* Mode 7 */
/***********************************************************/

float2 Fun_Mode7(float2 In: TEXCOORD)
{
    float2  _UV = In;

        _UV.x -= -_OffsetX + 0.5;
        _UV /= (In.y * _Distortion) - 0.5;

    return _UV * _PosZ;
}

float2 Fun_RotationX(float2 In: TEXCOORD)
{
    float2  _UV = float2((In.x + _PointX) / 2.0, (In.y + _PointY) / 2.0);
    _RotX = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotX), sin(_RotX), -sin(_RotX), cos(_RotX)), _UV);

    return _UV;

}

float2 Fun_RotationY(float2 In: TEXCOORD)
{
    _RotY = (_RotY - 180) * (3.14159265 / 180);

        In = 0.5 + mul(float2x2(cos(_RotY), sin(_RotY), -sin(_RotY), cos(_RotY)), In - 0.5);

        In.x = 1 - In.x;

    return In;

}

/************************************************************/
/* Main */
/************************************************************/

float4 Main(float2 In: TEXCOORD) : COLOR
{   
        In = Fun_RotationY(In);

    _RotZ = _RotZ * (3.14159265 / 180);

        float2 _In_Old = In;
        In.y += _RotZ;

    float2  _UV = Fun_Mode7(In),
            _Pos = float2(-_PosX, _PosY),
            _Scale = (float2(_ScaleX, _ScaleY)) * _Scale;

    _UV = Fun_RotationX(_UV);
    _UV -= _Pos;
    _UV *= _Scale;

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

    /* Rendering */

    float4 _Render = 1;
    if(_Result == 0) { _Render = tex2D(S2D_Image, _UV); }
    else { _Render = tex2D(S2D_Background, _UV); }

        if (_Looping_Mode == 3 && (_UV.x < 0 || _UV.x > 1 || _UV.y < 0 || _UV.y > 1 || _UV.y < 0))
        {
            _Render = 0;
        }

        if(_Render_Sky == 0)
        {
            if(_In_Old.y > (0.5 / _Distortion) - _RotZ)
            {
                _Render = 0;
            }
        }
    
    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }