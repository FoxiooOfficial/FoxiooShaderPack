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
            _Emboss_Size,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _Off = _Emboss_Size * float2(fPixelWidth, fPixelHeight);
    float _Scale = _Mixing * max(1.0, _Emboss_Size);
    
        float2 _Emboss;

    if(_Blending_Mode == 0)
    {
        float3 _NW = tex2D(S2D_Image, In + float2(-_Off.x,  -_Off.y)).rgb;
        float3 _N  = tex2D(S2D_Image, In + float2(0.0,      -_Off.y)).rgb;
        float3 _NE = tex2D(S2D_Image, In + float2( _Off.x,  -_Off.y)).rgb;
        float3 _W  = tex2D(S2D_Image, In + float2(-_Off.x,   0.0))   .rgb;
        float3 _C  = tex2D(S2D_Image, In)                            .rgb;
        float3 _E  = tex2D(S2D_Image, In + float2( _Off.x,   0.0))   .rgb;
        float3 _SW = tex2D(S2D_Image, In + float2(-_Off.x,  _Off.y)) .rgb;
        float3 _S  = tex2D(S2D_Image, In + float2(0.0,      _Off.y)) .rgb;
        float3 _SE = tex2D(S2D_Image, In + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }
    else
    {
        float3 _NW = tex2D(S2D_Background, In + float2(-_Off.x,  -_Off.y)).rgb;
        float3 _N  = tex2D(S2D_Background, In + float2(0.0,      -_Off.y)).rgb;
        float3 _NE = tex2D(S2D_Background, In + float2( _Off.x,  -_Off.y)).rgb;
        float3 _W  = tex2D(S2D_Background, In + float2(-_Off.x,   0.0))   .rgb;
        float3 _C  = tex2D(S2D_Background, In)                            .rgb;
        float3 _E  = tex2D(S2D_Background, In + float2( _Off.x,   0.0))   .rgb;
        float3 _SW = tex2D(S2D_Background, In + float2(-_Off.x,  _Off.y)) .rgb;
        float3 _S  = tex2D(S2D_Background, In + float2(0.0,      _Off.y)) .rgb;
        float3 _SE = tex2D(S2D_Background, In + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }

            float _Diff = (_Emboss.x + _Emboss.y) * 0.5;
            float _Render_Emboss = saturate(0.5 + _Diff * _Scale);

        _Result.rgb = lerp(_Result.rgb, float3(_Render_Emboss, _Render_Emboss, _Render_Emboss), clamp(abs(_Mixing), 0.0, 1.0));
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
