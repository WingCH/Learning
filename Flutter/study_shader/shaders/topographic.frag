#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uPointer;
uniform float uPointerActive;
uniform float uPointerDirection;

out vec4 fragColor;

float hash21(vec2 point) {
  point = fract(point * vec2(123.34, 456.21));
  point += dot(point, point + 34.45);
  return fract(point.x * point.y);
}

float valueNoise(vec2 point) {
  vec2 cell = floor(point);
  vec2 local = fract(point);

  float a = hash21(cell);
  float b = hash21(cell + vec2(1.0, 0.0));
  float c = hash21(cell + vec2(0.0, 1.0));
  float d = hash21(cell + vec2(1.0, 1.0));

  vec2 curve = local * local * (3.0 - 2.0 * local);
  return mix(
    mix(a, b, curve.x),
    mix(c, d, curve.x),
    curve.y
  );
}

float fbm(vec2 point) {
  float sum = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;

  for (int octave = 0; octave < 5; octave++) {
    sum += valueNoise(point * frequency) * amplitude;
    frequency *= 2.0;
    amplitude *= 0.5;
  }

  return sum / 0.96875;
}

float contourMask(float value, float count, float widthScale) {
  float distanceToLine = min(fract(value * count), 1.0 - fract(value * count));
  float width = fwidth(value * count) * widthScale;
  return 1.0 - smoothstep(width, width * 2.6 + 0.0005, distanceToLine);
}

vec3 linePalette(float height) {
  vec3 coral = vec3(224.0, 120.0, 80.0) / 255.0;
  vec3 amber = vec3(200.0, 149.0, 108.0) / 255.0;
  vec3 gold = vec3(212.0, 165.0, 116.0) / 255.0;

  if (height < 0.5) {
    return mix(coral, amber, height * 2.0);
  }

  return mix(amber, gold, (height - 0.5) * 2.0);
}

float terrain(vec2 point) {
  vec2 flow = vec2(
    fbm(point * 0.85 + vec2(0.0, uTime * 0.08)),
    fbm(point * 0.85 + vec2(7.2, -uTime * 0.06))
  );

  vec2 warped = point + (flow - 0.5) * 0.8;
  float base = fbm(warped * 1.2 + vec2(uTime * 0.03, uTime * 0.02));
  float ridge = 1.0 - abs(fbm(warped * 2.15 - vec2(uTime * 0.05, -uTime * 0.03)) * 2.0 - 1.0);
  float detail = fbm(warped * 4.2 + vec2(-uTime * 0.06, uTime * 0.04));

  float elevation = mix(base, ridge, 0.24) + detail * 0.07;
  return clamp(elevation, 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;
  vec2 centered = uv - 0.5;
  centered.x *= uResolution.x / uResolution.y;

  vec2 point = centered * 3.4;
  float height = terrain(point);

  vec2 pointerUv = uPointer / uResolution;
  vec2 pointerDelta = uv - pointerUv;
  pointerDelta.x *= uResolution.x / uResolution.y;
  float pointerRadius = 0.22;
  float pointerFalloff = max(0.0, 1.0 - length(pointerDelta) / pointerRadius);
  height += uPointerActive * uPointerDirection * 0.42 * pointerFalloff * pointerFalloff;
  height = clamp(height, 0.0, 1.0);

  float minorGlow = contourMask(height, 15.0, 2.2);
  float minorSharp = contourMask(height, 15.0, 0.72);
  float majorGlow = contourMask(height, 3.0, 4.0);
  float majorSharp = contourMask(height, 3.0, 1.35);

  float centerWeight = 1.0 - abs(height - 0.5) * 2.0;
  float alphaBias = 0.25 + centerWeight * 0.45;

  vec3 background = mix(
    vec3(10.0, 10.0, 10.0) / 255.0,
    vec3(24.0, 18.0, 14.0) / 255.0,
    smoothstep(0.08, 0.92, height) * 0.18
  );

  vec3 palette = linePalette(height);
  vec3 color = background;
  color += palette * minorGlow * alphaBias * 0.14;
  color += palette * minorSharp * alphaBias * 0.40;
  color += palette * majorGlow * (0.12 + alphaBias * 0.24);
  color += palette * majorSharp * (0.22 + alphaBias * 0.52);

  float grain = hash21(fragCoord + vec2(uTime * 3.7, -uTime * 2.1)) - 0.5;
  color += grain * 0.015;

  float vignette = smoothstep(0.28, 1.1, length(centered));
  color *= 1.0 - vignette * 0.38;

  fragColor = vec4(color, 1.0);
}
