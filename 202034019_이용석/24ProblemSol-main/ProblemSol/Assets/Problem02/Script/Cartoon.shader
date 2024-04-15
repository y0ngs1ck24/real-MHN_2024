Shader "Custom/StarCartoonShader"
{
    Properties
    {
        _DiffuseColor("DiffuseColor", Color) = (1,1,1,1)
        _LightDirection("LightDirection", Vector) = (1,-1,-1,0)
    }

        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _DiffuseColor;
            float4 _LightDirection;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex); // View direction in world space
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); // Assuming a single directional light, you might need to adjust this if you have different lighting setup

                float ambientStrength = 0.2;
                float3 ambient = ambientStrength * float3(1.0, 1.0, 1.0);

                float diff = max(dot(normal, lightDir), 0.0);
                float3 diffuse = diff * float3(1.0, 0.0, 0.0); // Red diffuse color

                float3 reflectDir = reflect(-lightDir, normal);
                float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
                float3 specular = float3(0.5, 0.5, 0.5) * spec;


                float3 result = (ambient + diffuse + specular);

                // Apply a step function to create discrete shading bands
                float threshold = 0.4;
                float3 banding = floor(result / threshold);
                float3 finalIntensity = banding * threshold;

                return float4(finalIntensity, 1.0);
            }
            ENDCG
        }
    }
}