#version 300 es
precision highp float;

in vec2 v_uv;
uniform vec2 u_resolution;
uniform sampler2D u_webcam;
uniform float u_refractionIntensity;
uniform float u_nStrips;

out vec4 fragColor;

// Imagine cutting the image into nStrips strips along the x-axis. Then rearrange the strips so we take the first strip,
// then the last strip, then the second strip, then the second last strip, etc.
vec2 refractStrips(vec2 uv, vec2 nStrips) {
    vec2 scaledUv = uv * nStrips;
    vec2 stripUv = floor(scaledUv);
    vec2 localUv = fract(scaledUv);
    vec2 distFromCenter = (stripUv + 0.5 - nStrips / 2.0) / max(nStrips / 2.0 - 0.5, 1.0);
    vec2 offset = distFromCenter * u_refractionIntensity / nStrips;
    offset *= mix(localUv, 1.0 - localUv, step(0.0, distFromCenter));
    return uv - offset;
}

// Crop the texture to preserve its aspect ratio (object-fit: contain).
vec2 correctAspectRatio(vec2 uv, vec2 resolution, vec2 textureSize) {
    float canvasAspect = resolution.x / resolution.y;
    float textureAspect = textureSize.x / textureSize.y;
    vec2 scale = vec2(min(canvasAspect / textureAspect, 1.0), min(textureAspect / canvasAspect, 1.0));
    return (uv - 0.5) * scale + 0.5;
}

void main() {
    vec2 uv = v_uv;
    uv = refractStrips(uv, vec2(u_nStrips, u_nStrips));
    uv = correctAspectRatio(uv, u_resolution, vec2(textureSize(u_webcam, 0)));
    uv.x = 1.0 - uv.x;
    fragColor = texture(u_webcam, uv);
}
