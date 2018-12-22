﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "UnityShaderBook/Chapter6/DiffuseVertexLevel"
{
    Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	
	}

	Subshader{
		Pass{
			Tags { "LightMode" = "ForwardBase"}
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
		
			};

			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 color:COLOR;
		
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;

				return o;
		
			}

			fixed4 frag(v2f i):SV_TARGET{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	
	}
    FallBack "Diffuse"
}
