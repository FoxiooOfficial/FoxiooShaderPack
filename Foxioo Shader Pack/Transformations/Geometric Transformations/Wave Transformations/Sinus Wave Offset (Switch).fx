/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.6 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);

    MinFilter = Point; 
    MagFilter = Point;
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);

    MinFilter = Point; 
    MagFilter = Point;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosX, _PosY,
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,
            _Mixing, _Looping_Mode,
            
            _FreqX, _FreqY,
            _TimeX, _TimeY,
            _AmpX, _AmpY;

    bool    _Blending_Mode,
            _X, _Y;

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
        UV = Fun_RotationX((In + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        float2 _UV_Temp = UV;
        _UV_Temp.x += sin((UV.y + _TimeX) * _FreqX) * _AmpX * _X;
        _UV_Temp.y += sin((UV.x + _TimeY) * _FreqY) * _AmpY * _Y;

        UV = lerp(UV, _UV_Temp, _Mixing);

        if (_Looping_Mode == 0) {
            UV = frac((UV));
        }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.001, 0.999);
            }

    if(_Blending_Mode == 0) {   _Render = tex2D(S2D_Image, UV);  }
    else {                      _Render = float4(tex2D(S2D_Background, UV).rgb, _Render_Texture.a);  }

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }