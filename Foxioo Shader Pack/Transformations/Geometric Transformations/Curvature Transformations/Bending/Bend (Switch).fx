/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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
            _Angle, _Start,
            _TuneHead, _TuneTail, 
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,
            _Mixing;

    bool    _Blending_Mode;

    int     _Looping_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float _RotX_Fix = _RotX * (3.14159265 / 180);

        In = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), In - _Points);

    return In;
}

float2 Fun_Bend(float2 In)
{
    float2 _Point = float2(_PointX, _PointY);
    float2 _Center = In - _Point;
    float _Distance = length(_Center);
    
        float _Blend = ((_Distance - _Start) / (1.0 - _Start));
        float _Factor = step(_Start, _Distance);
    
            float _TuningFactor = lerp(_TuneTail, lerp(_TuneTail, _TuneHead, _Blend), _Factor);
    
    float _Ang = radians(_Angle) * _TuningFactor;
    float2 _Os = float2(cos(_Ang), sin(_Ang));
        
        float2x2 _Rot = float2x2(_Os.x, -_Os.y, _Os.y, _Os.x);
    
        return mul(_Rot, _Center) + _Point;
}

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    float4 _Render;

    float2  _Pos = float2(_PosX, _PosY),
        UV = Fun_RotationX((In + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

    UV = lerp(UV, Fun_Bend(UV), _Mixing);


        if (_Looping_Mode == 0) {
            UV = frac(UV);
        }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = tex2D(S2D_Image, UV);  }
    else {                      _Render = float4(tex2D(S2D_Background, UV).rgb, _Render_Texture.a);  }

        if (_Looping_Mode == 3 && any(UV <= 0.0 || UV >= 1.0))
        {
            _Render = 0;
        }

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }