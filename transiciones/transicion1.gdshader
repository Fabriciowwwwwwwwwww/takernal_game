shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 numberOfTiles = vec2(15.0, 8.4375);
uniform vec2 pixelsPerTile = vec2(16.0, 16.0);

void fragment() {
	vec2 uv = UV;

	vec2 positionInSquare = uv * numberOfTiles;

	vec2 pixelPosition = round(positionInSquare * pixelsPerTile);

	vec2 frac = fract(pixelPosition / pixelsPerTile);

	vec2 direction = abs(frac - 0.5);

	float value = direction.x + direction.y + uv.x + uv.y;

	if (value >= progress * 4.0) {
		if (!reverse) {
			discard;
		}
	} else {
		if (reverse) {
			discard;
		}
	}
}