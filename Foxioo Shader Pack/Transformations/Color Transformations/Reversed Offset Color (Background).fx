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

    float   _OffsetX, _OffsetY, _OffsetZ,
            _PosX, _PosY,
            _Mixing;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(float2 In: TEXCOORD) : COLOR
{   
        float4 _Render_Texture = tex2D(S2D_Image, frac(In + float2(_PosX, _PosY)));
        float4 _Render_Background = tex2D(S2D_Background, frac(In + float2(_PosX, _PosY)));

    float2 UV = In;

    float4 _Result = 0;
    float4 _Render = 0;

    if(_Blending_Mode == 1) 
    { 
        UV.x += (_Render_Texture.r + (_Render_Texture.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Texture.g + (_Render_Texture.b * _OffsetZ)) * _OffsetY;
        _Result = tex2D(S2D_Background, frac(UV)); 

        _Render = _Render_Texture;
    }
    else
    { 
        UV.x += (_Render_Background.r + (_Render_Background.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Background.g + (_Render_Background.b * _OffsetZ)) * _OffsetY;
        _Result = tex2D(S2D_Image, frac(UV)); 
        
        _Render = _Render_Background;
    }
    
    _Result = lerp(_Render, _Result, _Mixing);
    _Result.a *= _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }