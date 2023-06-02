#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define PARSON_IMPLEMENTATION
#include "parson.h"
#include "change_ext.h"

const char *default_map = "{\"tiledversion\":\"1.10.1\",\"type\":\"map\",\"version\":\"1.10\",\"compressionlevel\":-1,\"orientation\":\"orthogonal\",\"renderorder\":\"right-down\",\"infinite\":false,\"tilewidth\":8,\"tileheight\":8,\"width\":32,\"height\":30,\"layers\":[{\"data\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],\"id\":1,\"type\":\"tilelayer\",\"name\":\"Tile Layer\",\"x\":0,\"y\":0,\"width\":32,\"height\":30,\"opacity\":1,\"visible\":true}],\"tilesets\":[{\"firstgid\":1,\"name\":\"Tileset 1\",\"image\":\"\",\"tilecount\":256,\"tileheight\":8,\"tilewidth\":8,\"columns\":16,\"imageheight\":128,\"imagewidth\":128,\"margin\":0,\"spacing\":0},{\"firstgid\":257,\"name\":\"Tileset 2\",\"image\":\"\",\"tilecount\":256,\"tileheight\":8,\"tilewidth\":8,\"columns\":16,\"imageheight\":128,\"imagewidth\":128,\"margin\":0,\"spacing\":0}],\"properties\":[{\"name\":\"__atr__\",\"type\":\"QVariantList\",\"value\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},{\"name\":\"__pal__\",\"type\":\"QVariantList\",\"value\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}]}";

void write_array(const char *filename, JSON_Array *array, int offset) {
    FILE *fp = fopen(filename, "wb");
    for (int i = 0; i < array->count; i++) {
        int v = (int) array->items[i]->value.number + offset;
        fputc((char) (v % 256) , fp);
    }
    fclose(fp);
}

int main(int argc, char *argv[]) {
    char filename[2048];

    JSON_Value *json = json_parse_file(argv[1]);
    JSON_Object *root = json_value_get_object(json);
    
    int width = (int) json_object_get_number(root, "width");
    int height = (int) json_object_get_number(root, "height");

    JSON_Array *layers = json_object_get_array(root, "layers");
    JSON_Array *properties = json_object_get_array(root, "properties");
    JSON_Array *tilesets = json_object_get_array(root, "tilesets");

    JSON_Array *layer0    = json_object_get_array(json_array_get_object(layers, 0), "data");
    JSON_Array *attribute = json_object_get_array(json_array_get_object(properties, 0), "value");
    JSON_Array *palette   = json_object_get_array(json_array_get_object(properties, 1), "value");

    JSON_String *tileset0 = &json_object_get_value(json_array_get_object(tilesets, 0), "image")->value.string;
    JSON_String *tileset1 = &json_object_get_value(json_array_get_object(tilesets, 1), "image")->value.string;

    change_ext(filename, argv[1], "nt");
    write_array(filename, layer0, -1);
    
    change_ext(filename, argv[1], "nt_atr");
    write_array(filename, attribute, 0);
    
    change_ext(filename, argv[1], "nt_plt");
    write_array(filename, palette, 0);

    json_value_free(json);

    return 0;
}
