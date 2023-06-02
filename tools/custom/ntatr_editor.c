#include <stdio.h>
#include <stdint.h>

#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

#define PARSON_IMPLEMENTATION
#include "parson.h"


const char shader_src[] = 
"#version 330" "\n"
"" "\n"
"// Input vertex attributes (from vertex shader)" "\n"
"in vec2 fragTexCoord;" "\n"
"in vec4 fragColor;" "\n"
"" "\n"
"// Input uniform values" "\n"
"uniform sampler2D texture0;" "\n"
"" "\n"
"uniform vec4 col0;" "\n"
"uniform vec4 col1;" "\n"
"uniform vec4 col2;" "\n"
"uniform vec4 col3;" "\n"
"uniform bool drawPalette = true;" "\n"
"" "\n"
"// Output fragment color" "\n"
"out vec4 finalColor;" "\n"
"" "\n"
"void main() {" "\n"
"    vec2 uv = fragTexCoord;" "\n"
"    vec2 uv_cell = fract(fragTexCoord*16.0);" "\n"
"" "\n"
"    float g = texture(texture0, fragTexCoord).r;" "\n"
"" "\n"
"    if (drawPalette) {" "\n"
"        if (uv_cell.y < 0.5) {" "\n"
"            finalColor = uv_cell.x < 0.5 ? col0 : col1;" "\n"
"        } else {" "\n"
"            finalColor = uv_cell.x < 0.5 ? col2 : col3;" "\n"
"        }" "\n"
"    } else {" "\n"
"        if (g < 0.3) finalColor = col0;" "\n"
"        else if (g < 0.5) finalColor = col1;" "\n"
"        else if (g < 0.7) finalColor = col2;" "\n"
"        else finalColor = col3;" "\n"
"    }" "\n"
"" "\n"
"    // finalColor = vec4(fract(fragTexCoord*16.0), 0.0, 1.0);" "\n"
"}" "\n"
;

void json_load(const char *filename);
int json_save(const char *filename);
void json_unload();

void init(int argc, const char *argv[]);
void update(float delta);
void draw(float delta);
void fini();

const int window_width  = 512+32;
const int window_height = 512+64+64;
float dpi = 1.0f;
Camera2D camera = { .zoom = 1 };

void ToggleSize() {
    if (dpi == 1.0f) dpi = 1.5f;
    else if (dpi == 1.5f) dpi = 2.0f;
    else dpi = 1.0f;

    camera.zoom = dpi;
    SetMouseScale(1 / dpi, 1 / dpi);
    SetWindowSize((int) (window_width* dpi), (int) (window_height* dpi));
}

int main(int argc, const char *argv[]) {
    SetTraceLogLevel(LOG_WARNING);
    InitWindow(window_width, window_height, "NES Nametable Attributes Editor");
    // SetTargetFPS(60);
    // SetWindowState(FLAG_VSYNC_HINT);

	SetTextureFilter(GetFontDefault().texture, TEXTURE_FILTER_POINT);
    
    init(argc, argv);
    
    while (!WindowShouldClose()) {
        float delta = GetFrameTime();
        update(delta);

        BeginDrawing();
        BeginMode2D(camera);
        draw(delta);
        EndMode2D();
        EndDrawing();
    }
    fini();
        
    return 0;
}



JSON_Value *json;
JSON_Array *json_layer;
JSON_Array *json_attribute;
JSON_Array *json_palette;

uint16_t screen[960];
uint8_t screen_at[256];
uint8_t screen_pt[16];

char tileset0_path[1024];
char tileset1_path[1024];

void json_load(const char *filename) {
    json = json_parse_file(filename);
    JSON_Object *root = json_value_get_object(json);

    JSON_Array *layers = json_object_get_array(root, "layers");
    JSON_Array *properties = json_object_get_array(root, "properties");
    JSON_Array *tilesets = json_object_get_array(root, "tilesets");

    json_layer     = json_object_get_array(json_array_get_object(layers, 0), "data");
    json_attribute = json_object_get_array(json_array_get_object(properties, 0), "value");
    json_palette   = json_object_get_array(json_array_get_object(properties, 1), "value");

    JSON_String *tileset0 = &json_object_get_value(json_array_get_object(tilesets, 0), "image")->value.string;
    tileset0_path[0] = '\0';
    if (tileset0->length != 0) {
        strcat(tileset0_path, GetDirectoryPath(filename));
        strcat(tileset0_path, "/");
        strcat(tileset0_path, tileset0->chars);
    }

    JSON_String *tileset1 = &json_object_get_value(json_array_get_object(tilesets, 1), "image")->value.string;
    tileset1_path[0] = '\0';
    if (tileset1->length != 0) {
        strcat(tileset1_path, GetDirectoryPath(filename));
        strcat(tileset1_path, "/");
        strcat(tileset1_path, tileset1->chars);
    }

    for (int i = 0; i < json_layer->count; i++) {
        screen[i] = (int) json_layer->items[i]->value.number - 1;
    }

    for (int i = 0; i < json_palette->count; i++) {
        int col = (int) json_palette->items[i]->value.number;
        if (col == 0x0D) col = 0x1D;
        if ((col & 0x0F) == 0x0E) col = 0x1D;
        if ((col & 0x0F) == 0x0F) col = 0x1D;
        if (col == 0x20) col = 0x30;
        screen_pt[i] = col;
    }
    
    for (int i = 0; i < json_attribute->count; i++) {
        int x = (i % 8) * 2;
        int y = (i / 8) * 2;
        int z = y * 16 + x;

        int v = (int) json_attribute->items[i]->value.number;
        screen_at[z +  0] = (v >> 0) & 3;
        screen_at[z +  1] = (v >> 2) & 3;
        screen_at[z + 16] = (v >> 4) & 3;
        screen_at[z + 17] = (v >> 6) & 3;
    }
}

int json_save(const char *filename) {
    for (int i = 0; i < json_layer->count; i++) {
        json_layer->items[i]->value.number = screen[i] + 1;
    }

    for (int i = 0; i < json_palette->count; i++) {
        int col = screen_pt[i];
        // when 0x1D is selected change it to 0xF0 
        if (col == 0x1D) col = 0xF0;
        json_palette->items[i]->value.number = col;
    }
    
    for (int i = 0; i < json_attribute->count; i++) {
        int x = (i % 8) * 2;
        int y = (i / 8) * 2;
        int z = y * 16 + x;

        int v = 0;
        v |= (screen_at[z +  0] & 3) << 0;
        v |= (screen_at[z +  1] & 3) << 2;
        v |= (screen_at[z + 16] & 3) << 4;
        v |= (screen_at[z + 17] & 3) << 6;
        json_attribute->items[i]->value.number = v;
    }

    return json_serialize_to_file(json, filename);
}

void json_unload() {
    json_value_free(json);
    json = NULL;
    json_layer = NULL;
    json_attribute = NULL;
    json_palette = NULL;
}




#define ColorFromRGBA(rgba) {(uint8_t) ((rgba) >> 24), (uint8_t) ((rgba) >> 16), (uint8_t) ((rgba) >> 8), (uint8_t) ((rgba) >> 0)}

#define CL_APP_BG       (Color) ColorFromRGBA(0x333333ff)
#define CL_APP_BG2      (Color) ColorFromRGBA(0x222222ff)
#define CL_MENU_BG      (Color) ColorFromRGBA(0x555555ff)
#define CL_MENU_ELEM    (Color) ColorFromRGBA(0x888888ff)
#define CL_MENU_ELEM_H  (Color) ColorFromRGBA(0xaaaaaaff)


Color _nes_palette[64] = {
    ColorFromRGBA(0x545454ff), 
    ColorFromRGBA(0x001e74ff), 
    ColorFromRGBA(0x081090ff), 
    ColorFromRGBA(0x300088ff), 
    ColorFromRGBA(0x440064ff), 
    ColorFromRGBA(0x5c0030ff), 
    ColorFromRGBA(0x540400ff), 
    ColorFromRGBA(0x3c1800ff), 
    ColorFromRGBA(0x202a00ff), 
    ColorFromRGBA(0x083a00ff), 
    ColorFromRGBA(0x004000ff), 
    ColorFromRGBA(0x003c00ff), 
    ColorFromRGBA(0x00323cff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff), 

    ColorFromRGBA(0x989698ff), 
    ColorFromRGBA(0x084cc4ff), 
    ColorFromRGBA(0x3032ecff), 
    ColorFromRGBA(0x5c1ee4ff), 
    ColorFromRGBA(0x8814b0ff), 
    ColorFromRGBA(0xa01464ff), 
    ColorFromRGBA(0x982220ff), 
    ColorFromRGBA(0x783c00ff), 
    ColorFromRGBA(0x545a00ff), 
    ColorFromRGBA(0x287200ff), 
    ColorFromRGBA(0x087c00ff), 
    ColorFromRGBA(0x007628ff), 
    ColorFromRGBA(0x006678ff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff), 

    ColorFromRGBA(0xeceeecff), 
    ColorFromRGBA(0x4c9aecff), 
    ColorFromRGBA(0x787cecff), 
    ColorFromRGBA(0xb062ecff), 
    ColorFromRGBA(0xe454ecff), 
    ColorFromRGBA(0xec58b4ff), 
    ColorFromRGBA(0xec6a64ff), 
    ColorFromRGBA(0xd48820ff), 
    ColorFromRGBA(0xa0aa00ff), 
    ColorFromRGBA(0x74c400ff), 
    ColorFromRGBA(0x4cd020ff), 
    ColorFromRGBA(0x38cc6cff), 
    ColorFromRGBA(0x38b4ccff), 
    ColorFromRGBA(0x3c3c3cff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff), 

    ColorFromRGBA(0xeceeecff), 
    ColorFromRGBA(0xa8ccecff), 
    ColorFromRGBA(0xbcbcecff), 
    ColorFromRGBA(0xd4b2ecff), 
    ColorFromRGBA(0xecaeecff), 
    ColorFromRGBA(0xecaed4ff), 
    ColorFromRGBA(0xecb4b0ff), 
    ColorFromRGBA(0xe4c490ff), 
    ColorFromRGBA(0xccd278ff), 
    ColorFromRGBA(0xb4de78ff), 
    ColorFromRGBA(0xa8e290ff), 
    ColorFromRGBA(0x98e2b4ff), 
    ColorFromRGBA(0xa0d6e4ff), 
    ColorFromRGBA(0xa0a2a0ff), 
    ColorFromRGBA(0x000000ff), 
    ColorFromRGBA(0x000000ff),
};

struct ColorF { float r, g, b, a; } nes_palette[64];

Texture2D tx_tileset0;
Texture2D tx_tileset1;
Texture2D tx_palette;

Shader shader;
int col0Loc = -1;
int col1Loc = -1;
int col2Loc = -1;
int col3Loc = -1;
int drawPaletteLoc = -1;

RenderTexture2D target;

const char *i_filename = NULL;


void init(int argc, const char *argv[]) {
    for (int i = 0; i < 64; i++) {
        Color col = _nes_palette[i];
        nes_palette[i] = (struct ColorF) { 
            col.r / 255.0f, col.g / 255.0f, col.b / 255.0f, col.a / 255.0f 
        };
    }

    i_filename = argv[1];
    json_load(argv[1]);
    
    Image image0 = LoadImage(tileset0_path);
    Image image1 = LoadImage(tileset1_path);
    tx_tileset0 = LoadTextureFromImage(image0);
    tx_tileset1 = LoadTextureFromImage(image1);
    UnloadImage(image0);
    UnloadImage(image1);

    target = LoadRenderTexture(256, 240);

    shader = LoadShaderFromMemory(NULL, shader_src);
    col0Loc = GetShaderLocation(shader, "col0");
    col1Loc = GetShaderLocation(shader, "col1");
    col2Loc = GetShaderLocation(shader, "col2");
    col3Loc = GetShaderLocation(shader, "col3");
    drawPaletteLoc = GetShaderLocation(shader, "drawPalette");
}

void fini() {
    printf("fini\n");

    UnloadTexture(tx_tileset0);
    UnloadTexture(tx_tileset1);
    UnloadShader(shader);

    json_unload();
}



Vector2 mouse;

struct {
    struct  {
        int x, y;
        bool dirty;
        int  drawPalette;
        bool drawDebug;
        float debugOpacity;
    } nt;
    struct {
        int hovered;
        int selected;
        uint8_t index;
    } pt;
} state = {
    .nt = {
        .dirty = true,
        .drawPalette = false,
        .debugOpacity = 0.5f
    },
    .pt = {
        .selected = -1
    }
};


void DrawCross(int x, int y, int scale, int weight) {
    DrawLineEx(
        (Vector2) { x, y }, 
        (Vector2) { x + scale, y + scale }, 
        weight, RED
    );
    DrawLineEx(
        (Vector2) { x + scale, y }, 
        (Vector2) { x, y + scale }, 
        weight, RED
    );
}

void DrawHightlightRect(int x, int y, int scale, int weight) {
    DrawRectangleLinesEx((Rectangle) {
        x-weight, y-weight, scale+2*weight, scale+2*weight
    }, weight, RED);
}

void DrawSelectedRect(int x, int y, int scale) {
    DrawRectangleLinesEx((Rectangle) {
        x-1, y-1, scale+2, scale+2
    }, 1, BLACK);
    DrawRectangleLinesEx((Rectangle) {
        x, y, scale, scale
    }, 1, WHITE);
}

void RenderNametableToRenderTexture() {
    BeginTextureMode(target);
    SetShaderValue(shader, drawPaletteLoc, &state.nt.drawPalette, SHADER_UNIFORM_INT);
    for (int p=0; p<4; p++) {
        SetShaderValue(shader, col0Loc, &nes_palette[screen_pt[p * 4 + 0]], SHADER_UNIFORM_VEC4);
        SetShaderValue(shader, col1Loc, &nes_palette[screen_pt[p * 4 + 1]], SHADER_UNIFORM_VEC4);
        SetShaderValue(shader, col2Loc, &nes_palette[screen_pt[p * 4 + 2]], SHADER_UNIFORM_VEC4);
        SetShaderValue(shader, col3Loc, &nes_palette[screen_pt[p * 4 + 3]], SHADER_UNIFORM_VEC4);

        BeginShaderMode(shader);
        for (int y=0; y<30; y++)
        for (int x=0; x<32; x++) {
            int p_idx = screen_at[(y >> 1) * 16 + (x >> 1)];
            int idx = screen[32*y+x];

            if (p_idx != p) continue;

            if (idx >=256) {
                idx -= 256;
                DrawTexturePro(tx_tileset1, (Rectangle) {(idx % 16) * 8, (idx / 16) * 8, 8, 8}, (Rectangle) {x*8, y*8, 8, 8}, (Vector2) {0, 0}, 0, WHITE);
            } else {
                DrawTexturePro(tx_tileset0, (Rectangle) {(idx % 16) * 8, (idx / 16) * 8, 8, 8}, (Rectangle) {x*8, y*8, 8, 8}, (Vector2) {0, 0}, 0, WHITE);
            }
        }
        EndShaderMode();
    }
    EndTextureMode();
}

void DrawNametable(float x, float y, float scale, int selected) {
    DrawTexturePro(target.texture, 
        (Rectangle) { 0, 0, 256, -240 }, 
        (Rectangle) { 0, 240 * scale, 256 * scale, 240 * scale }, 
        (Vector2)   { -x, -y + 240 * scale }, 0, WHITE);

    state.nt.x = (int) floorf((mouse.x - x) / scale / 8);
    state.nt.y = (int) floorf((mouse.y - y) / scale / 8);

    if (state.nt.x < 0 || state.nt.x > 31 || state.nt.y < 0 || state.nt.y > 29) {
        state.nt.x = -1;
        state.nt.y = -1;
    } else {
        DrawHightlightRect(
            (state.nt.x / 2)*16*scale + x, 
            (state.nt.y / 2)*16*scale + y, 
            16*scale, 2
        );
    }
    
    uint8_t opacity = (uint8_t) (state.nt.debugOpacity * 255);
    if (state.nt.drawDebug == 1)
    for (int my=0; my<15; my++)
    for (int mx=0; mx<16; mx++) {
        int p_idx = screen_at[my * 16 + mx];
        Font font = GetFontDefault();
        DrawTextCodepoint(font, '0'+p_idx, (Vector2) { mx*16*scale+x+8+2, my*16*scale+y+8+2}, (int) (10*scale), (Color) ColorFromRGBA(0x00000000|opacity));
        DrawTextCodepoint(font, '0'+p_idx, (Vector2) { mx*16*scale+x+8, my*16*scale+y+8}, (int) (10*scale), (Color) ColorFromRGBA(0xFFFFFF00|opacity));
        DrawRectangleLines(
            mx*16*scale+x,
            my*16*scale+y,
            16*scale+1,
            16*scale+1,
            (Color) ColorFromRGBA(0xFF000000|opacity)
        );
    }
}

void DrawPalette(float x, float y, float scale, int index) {
    for (int i=0; i<4; i++) {
        DrawRectangle(i*scale+x, y, scale, scale, _nes_palette[screen_pt[index*4+i]]);
    }

    if (state.pt.selected >= 0 && state.pt.selected < 4) {
        DrawSelectedRect(state.pt.selected*scale+x, y, scale);
    }
    
    int hovered = (int) floorf((mouse.x - x) / scale);

    if (hovered < 0 || hovered > 3 || mouse.y < y || mouse.y > y + scale) {
        hovered = -1;
        // if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
        //     state.pt.selected = -1;
        // }
    } else {
        DrawHightlightRect(hovered*scale+x, y, scale, 2);
        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
            state.pt.selected = hovered;
        }
    }

    state.pt.hovered = hovered;
}

void DrawNesPalette(float x, float y, float scale) {
    for (int j=0; j<4; j++)
    for (int i=0; i<14; i++) {
        DrawRectangle(i*scale+x, j*scale+y, scale, scale, _nes_palette[j*16+i]);
    }

    // cross out 0x0D and 0x20
    DrawCross(0xD*scale+x, 0x0*scale+y, scale, 1);
    DrawCross(0x0*scale+x, 0x2*scale+y, scale, 1);

    int mx = (int) floorf((mouse.x - x) / scale);
    int my = (int) floorf((mouse.y - y) / scale);
    int idx = mx | (my << 4);

    if (!(mx < 0 || mx > 13 || my < 0 || my > 3 || idx == 0x0D || idx == 0x20)) {
        DrawHightlightRect(
            mx*scale + x, my*scale + y, scale, 2
        );
        if (state.pt.selected != -1 && IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
            if (state.pt.selected == 0) {
                screen_pt[0] = screen_pt[4] = screen_pt[8] = screen_pt[12] = idx; 
            } else {
                screen_pt[state.pt.index * 4 + state.pt.selected] = idx;
            }
            state.nt.dirty = true;
        }
    }

    if (state.pt.selected != -1) {
        uint8_t pal = screen_pt[state.pt.index * 4 + state.pt.selected];
        uint8_t px = pal & 0x0F;
        uint8_t py = pal >> 4;
        DrawSelectedRect(px*scale + x, py*scale + y, scale);
    }
}

void update(float delta) {
    if (state.nt.dirty) {
        RenderNametableToRenderTexture();
        state.nt.dirty = false;
    }
    
    mouse = GetMousePosition();
    
    if (IsMouseButtonDown(MOUSE_BUTTON_LEFT) && state.nt.x != -1) {
        screen_at[
            (state.nt.y >> 1) * 16 + (state.nt.x >> 1)
        ] = state.pt.index;
        state.nt.dirty = true;
    }
    if (IsMouseButtonDown(MOUSE_BUTTON_RIGHT) && state.nt.x != -1) {
        state.pt.index = screen_at[
            (state.nt.y >> 1) * 16 + (state.nt.x >> 1)
        ];
    }

    if (IsKeyPressed(KEY_ONE)) state.pt.index = 0;
    if (IsKeyPressed(KEY_TWO)) state.pt.index = 1;
    if (IsKeyPressed(KEY_THREE)) state.pt.index = 2;
    if (IsKeyPressed(KEY_FOUR)) state.pt.index = 3;

    if (IsKeyPressed(KEY_S) && (IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_RIGHT_CONTROL))) {
        json_save(i_filename);
    }

    if (IsKeyDown(KEY_ESCAPE)) { 
        CloseWindow(); 
    }
}

void draw(float delta) {
    static bool cb_1 = false;

    ClearBackground(CL_APP_BG);

    int tile_scale = 3; 

    DrawNametable(16, 16+32, 2, -1);
    DrawText(TextFormat("Selected Palette: %d", state.pt.index), 16, 512+32, 20, WHITE);
    DrawNesPalette(512+16-20*14, 512+32, 20);
    DrawPalette(16, 512+4*20-48+32, 48, state.pt.index);

    DrawRectangle(0, 0, window_width, 32, CL_APP_BG2);
    // DrawText("Palette: 1,2,3,4  Save: CTRL+S", 8, 6, 20, WHITE);

    if (GuiLabelButton((Rectangle) { window_width-28, 4, 24, 24 }, "#193#")) {
        ToggleSize();
    }

    int oldDrawPalette = state.nt.drawPalette;
    state.nt.drawPalette = GuiCheckBox((Rectangle) { 8, 8, 16, 16 }, "Palette", state.nt.drawPalette);
    state.nt.drawDebug   = GuiCheckBox((Rectangle) { 8+72, 8, 16, 16 }, "Debug", state.nt.drawDebug);
    state.nt.debugOpacity = GuiSlider((Rectangle)  { 8+136, 8, 100, 16 }, "", "Opacity", state.nt.debugOpacity, 0, 1);

    if (state.nt.drawPalette != oldDrawPalette) {
        state.nt.dirty = true;
    }

}
