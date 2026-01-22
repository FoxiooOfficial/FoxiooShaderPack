/***********************************************************/

/* Shader author: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.4 (09.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
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
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

/*
static const float _Error   = 1e-6;
static const float _Range   = 0.001;
static const float _Out     = -1.0;

float Fun_Quad_Dist(float2 UV, float2 A, float2 B) { return (B.x - A.x) * (UV.y - A.y) - (B.y - A.y) * (UV.x - A.x); }

bool Fun_Quad_Vertex(float2 UV, float2 A, float2 B, float2 C, float2 D)
{
    float _V1 = Fun_Quad_Dist(UV, A, B);
    float _V2 = Fun_Quad_Dist(UV, B, C);
    float _V3 = Fun_Quad_Dist(UV, C, D);
    float _V4 = Fun_Quad_Dist(UV, D, A);

    float4 _Vertex = float4(_V1, _V2, _V3, _V4);

        bool _IsPos = any(_Vertex > 0.0);
        bool _IsNeg = any(_Vertex < 0.0);
    
    return !(_IsPos && _IsNeg);
}

float2 Fun_Quad(float2 UV)
{
    float2 A = float2(xA, yA);
    float2 B = float2(xB, yB);
    float2 C = float2(xC, yC);
    float2 D = float2(xD, yD);
    
    if (!Fun_Quad_Vertex(UV, A, B, C, D))   return float2(_Out, _Out);

        float a2 = xB - xA;
        float a3 = xD - xA;
        float a4 = xA - xB + xC - xD;

        float b2 = yB - yA;
        float b3 = yD - yA;
        float b4 = yA - yB + yC - yD;

            float aa = a4 * b3 - a3 * b4;
            float bb = a4 * yA - xA * b4 + a2 * b3 - a3 * b2 + UV.x * b4 - UV.y * a4;
            float cc = a2 * yA - xA * b2 + UV.x * b2 - UV.y * a2;

            float l = _Out;
            float m = _Out;

    if (abs(aa) < _Error)
    {
        if (abs(a2 * b3 - a3 * b2) < _Error)   return float2(_Out, _Out);
            
        m = -cc / bb;
        float denom = a2 + a4 * m;

            if (abs(denom) < _Error)   return float2(_Out, _Out);
            
        l = (UV.x - xA - a3 * m) / denom;
    }
    else
    {
        float det = bb * bb - 4.0 * aa * cc;
        if (det < 0.0)  return float2(_Out, _Out);

        det = sqrt(det);
        
            float m1 = (-bb + det) / (2.0 * aa);
            float m2 = (-bb - det) / (2.0 * aa);
            
            float l1, l2;

                bool validUwU = 0;
                bool validOwO = 0;
        
        float denom1 = a2 + a4 * m1;

        if (abs(denom1) > _Error)
        {
            l1 = (UV.x - xA - a3 * m1) / denom1;

                bool2 _SuperUwUCheck = bool2(       l1 >= -_Range && l1 <= 1.0 + _Range,
                                                    m1 >= -_Range && m1 <= 1.0 + _Range     );

                            validUwU = all(_SuperUwUCheck);
            
            if (validUwU) { l = l1; m = m1; }
        }
        
        float denom2 = a2 + a4 * m2;

        if (abs(denom2) > _Error)
        {
            l2 = (UV.x - xA - a3 * m2) / denom2;
            
                bool2 _SuperOwOCheck = bool2(       l2 >= -_Range && l2 <= 1.0 + _Range,
                                                    m2 >= -_Range && m2 <= 1.0 + _Range     );

                            validOwO = all(_SuperOwOCheck);
            
            if (validOwO)
            {
                if (validUwU)
                {
                    float2 sol1 = float2(l1, m1);
                    float2 sol2 = float2(l2, m2);
                    
                    if (distance(sol2, 0.5) < distance(sol1, 0.5))  l = l2; m = m2;
                }
                else { l = l2;  m = m2; }
            }
        }
        
        if (!validUwU && !validOwO)    return float2(_Out, _Out);
    }
    
            bool2 _SuperAwACheck = bool2(       l >= -_Range && l <= 1.0 + _Range,
                                                m >= -_Range && m <= 1.0 + _Range     );
    
                        if (all(_SuperAwACheck)) return saturate(float2(l, m));
    
    return float2(_Out, _Out);
}
*/

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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float2 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _In.xy) * In.Tint;

    float _Luminance = dot(_Render_Texture.rgb, float3(0.299, 0.587, 0.114));
;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, 1.0 - abs(frac((float2(In.texCoord.x, In.texCoord.y) + float2(_PosX, _PosY)) / 2.0) * 2.0 - 1.0));
    float _Luminance_Background = dot(_Render_Background.rgb, float3(0.299, 0.587, 0.114));

        _Render_Texture.rgb = lerp(_Render_Texture.rgb, _Render_Background.rgb * _Render_Texture.rgb * 1.5, _Mixing);
        _Render_Texture.rgb += dot(S2D_Image.Sample(S2D_ImageSampler, frac(_In + _Luminance_Background * 0.1 * _In)).rgb * In.Tint.rgb, float3(0.299, 0.587, 0.114)) * _Luminance_Background * _Mixing;

        if(any(_In <= 0.0 || _In >= 1.0)) _Render_Texture.a = 0;

    Out.Color = _Render_Texture;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float2 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _In.xy) * In.Tint;

    float _Luminance = dot(_Render_Texture.rgb, float3(0.299, 0.587, 0.114));
;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, 1.0 - abs(frac((float2(In.texCoord.x, In.texCoord.y) + float2(_PosX, _PosY)) / 2.0) * 2.0 - 1.0));
    float _Luminance_Background = dot(_Render_Background.rgb, float3(0.299, 0.587, 0.114));

        _Render_Texture.rgb = lerp(_Render_Texture.rgb, _Render_Background.rgb * _Render_Texture.rgb * 1.5, _Mixing);
        _Render_Texture.rgb += dot(S2D_Image.Sample(S2D_ImageSampler, frac(_In + _Luminance_Background * 0.1 * _In)).rgb * In.Tint.rgb, float3(0.299, 0.587, 0.114)) * _Luminance_Background * _Mixing;

        if(any(_In <= 0.0 || _In >= 1.0)) _Render_Texture.a = 0;

    _Render_Texture.rgb *= _Render_Texture.a;
    Out.Color = _Render_Texture;
    return Out;
}