/***********************************************************/

/* Shader author: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.1 (09.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;

    AddressU = Border;
    AddressV = Border;

    BorderColor = float4(0, 0, 1, 0);
};

sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float _Mixing;
    float _PosX;
    float _PosY;
    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Quad(float2 UV)
{
    float a = (xA - UV.x) * (yB - UV.y) - (xB - UV.x) * (yA - UV.y);
    float b = (xB - UV.x) * (yC - UV.y) - (xC - UV.x) * (yB - UV.y);
    float c = (xC - UV.x) * (yD - UV.y) - (xD - UV.x) * (yC - UV.y);
    float d = (xD - UV.x) * (yA - UV.y) - (xA - UV.x) * (yD - UV.y);

    if (sign(a)==sign(b) && sign(b)==sign(c) && sign(c)==sign(d))
    {
        float a1 = xA;
        float a2 = xB - xA;
        float a3 = xD - xA;
        float a4 = xA - xB + xC - xD;

        float b1 = yA;
        float b2 = yB - yA;
        float b3 = yD - yA;
        float b4 = yA - yB + yC - yD;

        float aa = a4 * b3 - a3 * b4;
        float bb = a4 * b1 - a1 * b4 + a2 * b3 - a3 * b2 + UV.x * b4 - UV.y * a4;
        float cc = a2 * b1 - a1 * b2 + UV.x * b2 - UV.y * a2;

            float eps = 1e-6;
            float m;

                if (abs(aa) < eps) { m = -cc / bb; }
                else
                {
                    float det = sqrt(bb*bb - 4.0*aa*cc);
                    m = (-bb + det) / (2.0 * aa);
                }

        float denom = a2 + a4 * m;
        float l = (UV.x - a1 - a3 * m) / denom;

        return float2(l, m);
    }
    else return -1;

}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{  
    float2 _In = Fun_Quad(In);

    float4 _Render_Texture = tex2D(S2D_Image, _In.xy);

    float _Luminance = dot(_Render_Texture.rgb, float3(0.299, 0.587, 0.114));

    float4 _Render_Background = tex2D(S2D_Background, 1.0 - abs(frac((float2(In.x, In.y) + float2(_PosX, _PosY)) / 2.0) * 2.0 - 1.0));
    float _Luminance_Background = dot(_Render_Background.rgb, float3(0.299, 0.587, 0.114));

        _Render_Texture.rgb = lerp(_Render_Texture.rgb, _Render_Background.rgb * _Render_Texture.rgb * 1.5, _Mixing);
        _Render_Texture.rgb += dot(tex2D(S2D_Image, frac(_In + _Luminance_Background * 0.1 * _In)).rgb, float3(0.299, 0.587, 0.114)) * _Luminance_Background * _Mixing;

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } };