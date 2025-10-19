/***********************************************************/

/* Autor shader: Foxioo */
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
            _ScaleX, _ScaleY, _Scale,
            _Mixing, _Looping_Mode;

    bool    _Blending_Mode, _X, _Y;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Fade(float _Times)    { return _Times * _Times * _Times * (_Times * (_Times * 6.0 - 15.0) + 10.0); }
float Fun_Hash(float2 _Pos)     {  return frac(sin(dot(_Pos, float2(127.1, 311.7))) * 43758.5453); }
float Fun_PerlinNoise(float2 _Pos)
{
    float2 _I = floor(_Pos);
    float2 _F = frac(_Pos);

    float _A = Fun_Hash(_I);
    float _B = Fun_Hash(_I + float2(1.0, 0.0));
    float _C = Fun_Hash(_I + float2(0.0, 1.0));
    float _D = Fun_Hash(_I + float2(1.0, 1.0));

    float2 _UV = float2(Fun_Fade(_F.x), Fun_Fade(_F.y));

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float2 Fun_Offset(float2 _Pos)
{
    float2 _UV = _Pos * 0.5;

    float _OffsetX = Fun_PerlinNoise(_UV + sin(_PosX + _UV));
    float _OffsetY = Fun_PerlinNoise(_UV + cos(_PosX + _UV));

        _OffsetX = (_OffsetX * 2.0 - 1.0) * 0.1;
        _OffsetY = (_OffsetY * 2.0 - 1.0) * 0.1;

    return float2(_OffsetX, _OffsetY);
}


float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float2 UV = lerp(In, In + Fun_PerlinNoise(In * float2(_ScaleX, _ScaleY) * _Scale + float2(_PosX, _PosY)), _Mixing);

    float4 _Render = 0;

            if(_Looping_Mode == 0)
            {
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
    else {                      _Render = float4(tex2D(S2D_Background, UV).rgb, _Render_Background.a);  }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        {
            _Render = 0;
        }

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }