/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (10.08.2025) */
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

    float   _PosX, _PosY,
            _ShearX, _ShearY,
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,
            _Mixing, _Looping_Mode;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Fix = _RotX * (3.14159265 / 180);

        _UV = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    float4 _Render;

    float2  _Pos = float2(_PosX, _PosY),
            UV = Fun_RotationX(In + _Pos);

        UV = (UV - 0.5) * float2(_ScaleX, _ScaleY) * _Scale + 0.5;

        float2 _Piv = In - float2(_PosX, _PosY);
        float2 _Shear = float2((_PointY - _Piv.y) * _ShearX, (_PointX - _Piv.x) * _ShearY);
        UV = lerp(UV, UV + _Shear, _Mixing);


        if (_Looping_Mode == 0) {
            UV = frac(UV);
        }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = tex2D(S2D_Image, UV);  }
    else {                      _Render = float4(tex2D(S2D_Background, UV).rgb, _Render_Texture.a);  }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        {
            _Render = 0;
        }

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }