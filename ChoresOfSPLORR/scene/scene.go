components {
  id: "scene"
  component: "/scene/scene.tilemap"
  position {
    x: 90.0
    y: 10.0
  }
}
components {
  id: "scene_script"
  component: "/scene/scene_script.script"
}
components {
  id: "inventory"
  component: "/scene/inventory.tilemap"
  position {
    x: 21.0
    y: 10.0
  }
}
embedded_components {
  id: "moves_label"
  type: "label"
  data: "size {\n"
  "  x: 90.0\n"
  "  y: 16.0\n"
  "}\n"
  "text: \"Moves: 9999\"\n"
  "font: \"/builtins/fonts/default.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    x: 435.0
    y: 18.0
  }
}
