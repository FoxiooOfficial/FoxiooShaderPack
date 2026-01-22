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

//sampler2D S2D_A : register(s2);
sampler2D _Texture_B : register(s2);
sampler2D _Texture_C : register(s3);
sampler2D _Texture_D : register(s4);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _B, _C, _D;

    bool    _Blending_Mode,
            _B_Mode, _C_Mode, _D_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

        /* (A - B) * C + D */
        //_Render =  _A_Mode ? tex2D(S2D_A, In) : _A;
        _Render -= _B_Mode ? tex2D(_Texture_B, In) * _B : _B;
        _Render *= _C_Mode ? tex2D(_Texture_C, In) * _C : _C;
        _Render += _D_Mode ? tex2D(_Texture_D, In) * _D : _D;

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
