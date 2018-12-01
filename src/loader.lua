map = require "src.map";

return function()
    love.graphics.setDefaultFilter("nearest", "nearest");

    images = {
        atlas = love.graphics.newImage("assets/atlas.png"),
        pixel = love.graphics.newImage("assets/pixel.png"),
    };

    quads = {
        -- ulc = love.graphics.newQuad(0, 0, 16, 16, images.atlas:getDimensions()),
        -- us = love.graphics.newQuad(16, 0, 16, 16, images.atlas:getDimensions()),
        -- center = love.graphics.newQuad(16, 16, 16, 16, images.atlas:getDimensions()),
        -- quads = {},
    };

    shaders = {};

    shaders.flashlight = love.graphics.newShader([[
        uniform float force;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            float distance = pow(texture_coords.x - .5, 2) + pow(texture_coords.y - .5, 2);
            return vec4(0, 0, 0, distance*force);
        }
    ]])

    local w, h = images.atlas:getDimensions();
    for i=0,(w-1)/16 do
        for j=0,(h-1)/16 do
            quads[#quads+1] = love.graphics.newQuad(j*16, i*16, 16, 16, images.atlas:getDimensions());
        end
    end

    local map_width = map.width;
    local map_height = map.height;
    local map_layers = map.layers;
    map_batch = love.graphics.newSpriteBatch(images.atlas, map_width * map_height * #map_layers);
    local x = 0;
    local y = 0;
    for i,layer in ipairs(map.layers) do
        for j,block in ipairs(layer.data) do
            if block>0 then
                map_batch:add(quads[block], x, y);
            end
            x = x + 16;
            if x>=map_width*16 then
                x = 0;
                y = y + 16;
            end
        end
    end

    print("Assets Loaded");
end;