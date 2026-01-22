/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (20.10.2026) */
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

    float _Mixing, _Time;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b); }

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result, _Render;

    if (_Blending_Mode == 0)
    {   
        _Render = _Render_Texture; 
        _Result = _Render_Texture;
    }
    else
    {
        _Render = _Render_Background; 
        _Result = _Render_Background;
    }
        const float3 _Color0 = float3(1.0, 1.0, 1.0); // Whi
        const float3 _Color1 = float3(1.0, 1.0, 0.0); // Yel
        const float3 _Color2 = float3(1.0, 0.0, 0.0); // Red
        const float3 _Color3 = float3(0.5, 0.0, 0.5); // Pur
        const float3 _Color4 = float3(0.0, 0.0, 0.25); // Blu
        const float3 _Color5 = float3(0.0, 0.0, 0.0); // Blk

        //_Result.rgb = pow(_Result.rgb, 2.2); 
        float _Lum = Fun_Lum(_Result);

        if(!_Blending_Mode) _Result = tex2D(S2D_Image, In + float2(_Lum * sin(_Lum + In.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.y * 400.0 * _Mixing + sin(In.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing));
        else                _Result = tex2D(S2D_Background, In + float2(_Lum * sin(_Lum + In.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + In.y * 400.0 * _Mixing + sin(In.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing));
        
        _Lum = Fun_Lum(_Result);
        if (_Lum < 0.2)         _Result.rgb = lerp(_Color5, _Color4, _Lum / 0.2);
        else if (_Lum < 0.4)    _Result.rgb = lerp(_Color4, _Color3, (_Lum - 0.2) / 0.2);
        else if (_Lum < 0.6)    _Result.rgb = lerp(_Color3, _Color2, (_Lum - 0.4) / 0.2);
        else if (_Lum < 0.8)    _Result.rgb = lerp(_Color2, _Color1, (_Lum - 0.6) / 0.2);
        else                    _Result.rgb = lerp(_Color1, _Color0, (_Lum - 0.8) / 0.2);

    _Result = lerp(_Render, _Result, _Mixing);
    _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
