/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (30.06.2024) */
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
            _AmplitudeX, _AmplitudeY,
            _FraqX, _FraqY,
            _PeriodsX, _PeriodsY,
            _Mixing;

    bool    _Blending_Mode, _X, _Y;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, frac(In));
    float4 _Render_Background = tex2D(S2D_Background, frac(In));

    float2 UV = In;
    if(_X == 1) { UV.x = In.x + ( _AmplitudeX * sin(((In.y *_PeriodsX) + _PosX) * _FraqX)); } else { In.x; }
    if(_Y == 1) { UV.y = In.y + ( _AmplitudeY * sin(((In.x *_PeriodsY) + _PosY) * _FraqY)); } else { In.y; }

    if(_Blending_Mode == 1)
    {   
        float4 _Render = tex2D(S2D_Image, frac(UV));

        return _Render * _Mixing;
    }
    else
    {   
        float4 _Render = tex2D(S2D_Background, frac(UV));

            _Render.a *= _Render_Texture.a;

        return _Render * _Mixing;
    }
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }