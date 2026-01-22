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

    float   _Mixing,
            _Seed,
            _Dimension,
            _Angle;

    bool    _Blending_Mode;

    int     _Looping_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(_Seed + sin(dot(_Pos - _Seed, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(_Seed + sin(dot(_Pos - _Seed, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

float2 Fun_Noise(float2 _Pos) 
{
    float2 _Noise = Fun_Hash21(_Pos);
    float2 _Dir = float2(cos(_Angle * (3.14159265 / 180.0)), sin(_Angle * (3.14159265 / 180.0)));

    _Noise = lerp(float2(_Noise.x, _Noise.x) * _Dir, _Noise, _Dimension);

    return _Noise;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float2 _UV = In;
        _UV += Fun_Noise(In) * _Mixing;

        if (_Looping_Mode == 0) {
            _UV = frac(_UV);
        }
            else if(_Looping_Mode == 1)
            {
                _UV /= 2;
                _UV = frac(_UV);
                _UV = abs(_UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                _UV = clamp(_UV, 0.0, 1.0);
            }

        float4 _Result = 0.0;

            float4 _Render_Texture_Noise = tex2D(S2D_Image, _UV);
            float4 _Render_Background_Noise = tex2D(S2D_Background, _UV);

        float4 _Render = _Blending_Mode ? _Render_Background_Noise : _Render_Texture_Noise;
        if(_Blending_Mode)  _Render.a = _Render_Texture.a;

        if (_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))
        {
            _Render = 0;
        }

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
