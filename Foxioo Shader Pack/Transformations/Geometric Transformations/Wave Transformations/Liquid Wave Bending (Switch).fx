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

    float   _Mixing,
            _Seed,
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,
            _OffsetX, _OffsetY,
            _PointX, _PointY,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

    int     _Looping_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos, float _SeedPlus)
{
    float2 _I = floor(_Pos + _Seed + _SeedPlus);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed + _SeedPlus);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed + _SeedPlus);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed + _SeedPlus);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed + _SeedPlus);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float2 Fun_Noise_Replay(float2 _Pos, float2 _Off)
{
    _Pos = Fun_Noise(_Pos + _Off + Fun_Noise(_Pos + _Off * 0.5 + Fun_Noise(_Pos + _Off * 0.25, 1), 2), 3);

    return _Pos;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    float4 _Render_Background = tex2D(S2D_Background, In);

        float2 _UV = ((In + float2(_PosX, _PosY) - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY); 
        
        float2 _Off = float2(_OffsetX, _OffsetY);
        _UV = lerp(_UV, Fun_Noise_Replay(_UV, _Off), _Mixing);
        
        if(_Looping_Mode == 0)      {   _UV = frac(_UV);    }
        else if(_Looping_Mode == 1) {   _UV = abs(frac(_UV / 2) * 2.0 - 1.0); }
        else if(_Looping_Mode == 2) {   _UV = clamp(_UV, 0.0, 1.0); }

            float4 _Result = _Blending_Mode ? float4(tex2D(S2D_Background, _UV).rgb, _Render_Texture.a) : tex2D(S2D_Image, _UV);

            if(_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))   _Result = 0;
            

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
