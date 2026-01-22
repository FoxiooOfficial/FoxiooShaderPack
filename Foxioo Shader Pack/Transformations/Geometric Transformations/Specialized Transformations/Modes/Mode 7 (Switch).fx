/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.9 (08.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state 
{
    MinFilter = POINT;
};
sampler2D S2D_Background : register(s1) = sampler_state 
{
    MinFilter = POINT;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosX, _PosY, _PosZ,

            _OffsetX,

            _ScaleX, _ScaleY, _Scale,

            _RotX, _RotY, _RotZ,
            _Distortion,

            _RotXPointX, _RotXPointY,
            _RotYPointX, _RotYPointY,

            _PosOffsetX, _PosOffsetY;

    int     _Looping_Mode;

    bool    _Render_Sky, _Blending_Mode;

#define RAD 0.0174532925

/***********************************************************/
/* Mode 7 */
/***********************************************************/

float2 Fun_Mode7(float2 In)
{
    float2 _UV = In;

        _UV.x += _OffsetX - 0.5;
        _UV /= (In.y * _Distortion) - 0.5;

    return _UV * _PosZ;
}

float2 Fun_RotationX(float2 In)
{
    float2 _UV = float2(In.x + _RotXPointX, In.y + _RotXPointY) * 0.5;

    float _RotX_Temp = _RotX * RAD;

        _UV = mul(float2x2(cos(_RotX_Temp), sin(_RotX_Temp), -sin(_RotX_Temp), cos(_RotX_Temp)), _UV);

    return _UV;

}

float2 Fun_RotationY(float2 In)
{
    float2 _UV = float2(In.x + _RotYPointX, In.y + _RotYPointY);

    float _RotY_Temp = (_RotY - 180.0) * RAD;

    _UV = 0.5 + mul(float2x2(cos(_RotY_Temp), sin(_RotY_Temp), -sin(_RotY_Temp), cos(_RotY_Temp)), _UV - 0.5);

    return _UV;
}

/************************************************************/
/* Main */
/************************************************************/

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    In = Fun_RotationY(In);

    float _RotZ_Temp = _RotZ * RAD;

    float2 _In_Old = In;
    In.y += _RotZ_Temp;

    float2  _UV = Fun_Mode7(In),
            _Pos = float2(-_PosX, _PosY),
            _PosOffset = float2(-_PosOffsetX, _PosOffsetY - 0.5),
            _Scale_Temp = (float2(_ScaleX, _ScaleY)) * _Scale;

            _UV = Fun_RotationX(_UV);
            _UV -= _PosOffset;
            _UV *= _Scale_Temp;
            _UV -= _Pos - 0.5;

    if(_Looping_Mode == 0)      {   _UV = frac(_UV);    }
    else if(_Looping_Mode == 1) {   _UV = abs(frac(_UV / 2.0) * 2.0 - 1.0);    }

    /* Rendering */
    float4 _Render;
    if(!_Blending_Mode) { _Render = tex2D(S2D_Image, _UV); }
    else { _Render = tex2D(S2D_Background, _UV); _Render.a = tex2D(S2D_Image, In).a; }

        if (_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))                  {   _Render = 0.0;    }
        if(((_In_Old.y + _RotZ_Temp) * _Distortion) > 0.5 && !_Render_Sky)      {   _Render = 0.0;    }

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
