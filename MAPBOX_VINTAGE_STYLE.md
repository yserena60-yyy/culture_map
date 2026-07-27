# Vintage Map Style Configuration Guide

## Mapbox Studio Setup

### 1. Create a New Style in Mapbox Studio

Visit [Mapbox Studio](https://studio.mapbox.com/) and create a new blank style.

### 2. Color Palette

```json
{
  "parchment_base": "#F5F0E6",
  "ink_brown": "#2C1810",
  "water_blue": "#9BAFAD",
  "land_green": "#B8C5A0",
  "road_sepia": "#8B7355",
  "border_dark": "#284139"
}
```

### 3. Layer Configuration

#### Background
```json
{
  "id": "background",
  "type": "background",
  "paint": {
    "background-color": "#F5F0E6"
  }
}
```

#### Water Bodies
```json
{
  "id": "water",
  "type": "fill",
  "source": "composite",
  "source-layer": "water",
  "paint": {
    "fill-color": "#9BAFAD",
    "fill-opacity": 0.6
  }
}
```

#### Land Use (Parks, Greenery)
```json
{
  "id": "landuse-park",
  "type": "fill",
  "source": "composite",
  "source-layer": "landuse",
  "filter": ["==", "class", "park"],
  "paint": {
    "fill-color": "#B8C5A0",
    "fill-opacity": 0.3
  }
}
```

#### Roads - Simplified
```json
{
  "id": "road-major",
  "type": "line",
  "source": "composite",
  "source-layer": "road",
  "filter": ["in", "class", "motorway", "trunk", "primary"],
  "paint": {
    "line-color": "#8B7355",
    "line-width": {
      "stops": [[10, 1], [15, 2], [18, 4]]
    },
    "line-dasharray": [1, 0.5],
    "line-opacity": 0.7
  }
}
```

#### Building Outlines (Hand-drawn Style)
```json
{
  "id": "building-outline",
  "type": "line",
  "source": "composite",
  "source-layer": "building",
  "paint": {
    "line-color": "#2C1810",
    "line-width": 1,
    "line-opacity": 0.4
  }
}
```

#### Place Labels (Serif Font)
```json
{
  "id": "place-label",
  "type": "symbol",
  "source": "composite",
  "source-layer": "place_label",
  "layout": {
    "text-field": "{name}",
    "text-font": ["EB Garamond Regular", "Noto Serif Regular"],
    "text-size": {
      "stops": [[10, 12], [15, 16]]
    }
  },
  "paint": {
    "text-color": "#2C1810",
    "text-halo-color": "#F5F0E6",
    "text-halo-width": 1.5
  }
}
```

### 4. Disable Unnecessary Layers

Remove or set opacity to 0 for:
- 3D buildings
- POI icons (we'll use custom markers)
- Minor roads
- Highways shields
- Transit lines

### 5. Get Your Style URL

After publishing, your style URL will be:
```
mapbox://styles/YOUR_USERNAME/YOUR_STYLE_ID
```

Replace `YOUR_USERNAME` and `YOUR_STYLE_ID` in `vintage_map_style.dart`.

## Custom Textures (Optional Enhancement)

### Parchment Texture Overlay

Add a subtle paper texture PNG as a raster layer:

1. Upload a parchment texture image to Mapbox Studio
2. Add as a raster layer with low opacity (0.05-0.1)
3. Blend mode: overlay

### Hand-drawn Border Effect

Use a custom line layer with:
- Irregular dash patterns
- Slight opacity variations
- Sepia tone

## Testing

1. Use Mapbox preview in Studio
2. Test at different zoom levels (10-18)
3. Verify readability on mobile devices
4. Check night mode compatibility (if needed)

## Performance Notes

- Simplified roads improve rendering speed
- Reduced label density
- No 3D features = better battery life
- Optimized for zoom levels 10-18

## Mapbox Alternatives

If you prefer a fully custom approach:
- Export OSM data
- Render with Leaflet + custom tile server
- Use Tangram for hand-drawn styling
