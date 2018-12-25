﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShaderBook/Chapter7/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_BumpMap("NormalMap",2D) = "bump"{}
		_BumpScale("BumpScale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20

    }
    SubShader
    {
        Pass{
			Tags{"LightMode" = "ForwardBase"}
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;

			};

			struct v2f{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;

			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3 (v.tangent.xyz ,binormal ,v.normal);

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			
			}

			fixed4 frag(v2f i):SV_TARGET{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;
				tangentNormal.xy = (packedNormal * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)),_Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);

			}
			ENDCG		
		}
    }
    FallBack "Specular"

}