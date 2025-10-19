/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};


/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _PosXRed, _PosYRed, _PosXGreen, _PosYGreen, _PosXBlue, _PosYBlue,

            _PointXRed, _PointYRed, _PointXGreen, _PointYGreen, _PointXBlue, _PointYBlue,

            _ScaleXRed, _ScaleYRed, _ScaleRed, _ScaleXGreen, _ScaleYGreen, _ScaleGreen, _ScaleXBlue, _ScaleYBlue, _ScaleBlue,

            _Mixing, _Looping_Mode;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_ChannelUV(float2 In, float _PosX, float _PosY, float _PointX, float _PointY, float _ScaleX, float _ScaleY, float _Scale)
{
    float2  _Pos = float2(_PosX, _PosY),
        UV = ((In - float2(_PointX, _PointY) + _Pos) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

    return UV;
}

float4 Main(float2 In: TEXCOORD) : COLOR
{   
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render;

    float2 _UVRed =     lerp(In, Fun_ChannelUV(In, _PosXRed, _PosYRed, _PointXRed, _PointYRed, _ScaleXRed, _ScaleYRed, _ScaleRed), _Mixing);
    float2 _UVGreen =   lerp(In, Fun_ChannelUV(In, _PosXGreen, _PosYGreen, _PointXGreen, _PointYGreen, _ScaleXGreen, _ScaleYGreen, _ScaleGreen), _Mixing);
    float2 _UVBlue =    lerp(In, Fun_ChannelUV(In, _PosXBlue, _PosYBlue, _PointXBlue, _PointYBlue, _ScaleXBlue, _ScaleYBlue, _ScaleBlue), _Mixing);


        if (_Looping_Mode == 0) {
            _UVRed = frac(_UVRed);
            _UVGreen = frac(_UVGreen);
            _UVBlue = frac(_UVBlue);
        }
        else if(_Looping_Mode == 1)
        {
            _UVRed = abs(frac(_UVRed / 2.0) * 2.0 - 1.0);
            _UVGreen = abs(frac(_UVGreen / 2.0) * 2.0 - 1.0);
            _UVBlue = abs(frac(_UVBlue / 2.0) * 2.0 - 1.0);
        }
        else if(_Looping_Mode == 2)
        {
            _UVRed = clamp(_UVRed, 0.0, 1.0);
            _UVGreen = clamp(_UVGreen, 0.0, 1.0);
            _UVBlue = clamp(_UVBlue, 0.0, 1.0);
        }

    if(_Blending_Mode == 0) {   _Render = float4(   tex2D(S2D_Image, _UVRed).r, 
                                                    tex2D(S2D_Image, _UVGreen).g, 
                                                    tex2D(S2D_Image, _UVBlue).b, 
                                                    tex2D(S2D_Image, _UVRed).a * tex2D(S2D_Image, _UVGreen).a * tex2D(S2D_Image, _UVBlue).a );  }

    else {                      _Render = float4(   tex2D(S2D_Background, _UVRed).r, 
                                                    tex2D(S2D_Background, _UVGreen).g, 
                                                    tex2D(S2D_Background, _UVBlue).b, 
                                                    _Render_Texture.a * tex2D(S2D_Image, _UVRed).a * tex2D(S2D_Image, _UVGreen).a * tex2D(S2D_Image, _UVBlue).a);             }


        //if (_Looping_Mode == 3)
        //{
        //    if (any(_UVRed < 0.0 || _UVRed > 1.0)) { _Render.r = 0.0; }
        //    if (any(_UVGreen < 0.0 || _UVGreen > 1.0)) { _Render.g = 0.0; }
        //    if (any(_UVBlue < 0.0 || _UVBlue > 1.0)) { _Render.b = 0.0; }
        //}

    return _Render;
    
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }