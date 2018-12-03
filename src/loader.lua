local map = require "src.map";

return function()
    love.graphics.setDefaultFilter("nearest", "nearest");

    images = {
        atlas = love.graphics.newImage("assets/atlas.png"),
        atlas2 = love.graphics.newImage("assets/atlas2.png"),
        pixel = love.graphics.newImage("assets/pixel.png"),
    };

    sounds_volume = 0; -- This just keeps track of the sounds volume

    sounds = {
        move = love.audio.newSource("assets/sfx/move.wav", "static"),
        disenchant = love.audio.newSource("assets/sfx/disenchant.wav", "static"),
        click = love.audio.newSource("assets/sfx/click.wav", "static"),
        pick = love.audio.newSource("assets/sfx/pick.wav", "static"),
        dead = love.audio.newSource("assets/sfx/dead.wav", "static"),
        upgrade = love.audio.newSource("assets/sfx/upgrade.wav", "static"),
        player = love.audio.newSource("assets/sfx/player.wav", "static"),
        buy = love.audio.newSource("assets/sfx/buy.wav", "static"),
        no = love.audio.newSource("assets/sfx/no.wav", "static"),
        monster = love.audio.newSource("assets/sfx/monster.wav", "static"),
        upgrade_finish = love.audio.newSource("assets/sfx/upgrade_finish.wav", "static"),
        see = love.audio.newSource("assets/sfx/see.ogg", "static"),
        unsee = love.audio.newSource("assets/sfx/unsee.ogg", "static"),

    };

    setmetatable(sounds, {
        __index = function(this, name)
            if name=="volume" then
                return sounds_volume;
            end
        end,
        __newindex = function(this, name, value)
            if name=="volume" then
                sounds_volume = value;
                for i,sound in pairs(this) do
                    sound:setVolume(value);
                end
            end
        end
    })

    sounds.volume = .5;

    
    music = {
        theme1 = love.audio.newSource("assets/theme1.ogg", "stream"),
        boss = love.audio.newSource("assets/boss.ogg", "stream"),
    };

    music.theme1:setLooping(true);
    music.boss:setLooping(true);

    setmetatable(music, {
        __index = function(this, name)
            if name=="volume" then
                return music_volume;
            end
        end,
        __newindex = function(this, name, value)
            if name=="volume" then
                music_volume = value;
                for i,music in pairs(this) do
                    music:setVolume(value);
                end
            end
        end
    })

    music.volume = 0;

    quads = {
        -- ulc = love.graphics.newQuad(0, 0, 16, 16, images.atlas:getDimensions()),
        -- us = love.graphics.newQuad(16, 0, 16, 16, images.atlas:getDimensions()),
        -- center = love.graphics.newQuad(16, 16, 16, 16, images.atlas:getDimensions()),
        -- quads = {},
    };

    quads2 = {

    };

    fonts = {
        square = love.graphics.newFont("assets/fonts/ChevyRay - Softsquare.ttf", 9),
        skullboy = love.graphics.newFont("assets/fonts/ChevyRay - Skullboy.ttf", 16),
        lantern = love.graphics.newFont("assets/fonts/ChevyRay - Lantern.ttf", 17),
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

    -- local pixelcode = [[
    --     vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
    --     {
    --         vec4 texcolor = Texel(texture, texture_coords);
    --         return texcolor * color;
    --     }
    -- ]]
    
    -- local vertexcode = [[
    --     uniform float time;

    --     float __map(float n, float start1, float stop1, float start2, float stop2){
    --         return (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
    --     }

    --     vec4 position( mat4 transform_projection, vec4 vertex_position )
    --     {
    --         vertex_position.x += __map(sin((time+vertex_position.x)*2), -1, 1, -2, 2);
    --         vertex_position.y += __map(sin((time+vertex_position.x)*2), -1, 1, -2, 2);
    --         return transform_projection * vertex_position;
    --     }
    -- ]]
    
    -- shaders.test = love.graphics.newShader(pixelcode, vertexcode);

    local w, h = images.atlas:getDimensions();
    for i=0,(w-1)/16 do
        for j=0,(h-1)/16 do
            quads[#quads+1] = love.graphics.newQuad(j*16, i*16, 16, 16, images.atlas:getDimensions());
        end
    end

    local w, h = images.atlas2:getDimensions();
    for i=0,(w-1)/16 do
        for j=0,(h-1)/16 do
            quads2[#quads2+1] = love.graphics.newQuad(j*16, i*16, 16, 16, images.atlas2:getDimensions());
        end
    end

    local map_width = map.width;
    local map_height = map.height;
    local map_layers = map.layers;
    map_batches = {};
    local x = 0;
    local y = 0;

    local map_row = {};
    local over_row = {};
    map_matrix = {};
    over_matrix = {};

    for i,layer in ipairs(map.layers) do
        map_batches[i] = love.graphics.newSpriteBatch(images.atlas, map_width * map_height);
        x = 0;
        y = 0;
        for j,block in ipairs(layer.data) do
            if block>0 then
                map_batches[i]:add(quads[block], x, y);
            end
            if i==1 then
                map_row[#map_row+1] = block;
            else
                if block==14 or block==15 or block==16 or block==28 then
                    local name = block==14 and "Depressed Orc" or "Cute Ghost";

                    if block==28 then
                        name = "Schizophrenic Snowman";
                    end

                    over_row[#over_row+1] = {
                        heal = 100,
                        heald = 100,
                        name = name,
                        id = block,
                        x = x,
                        y = y,
                    };
                else
                    over_row[#over_row+1] = block;
                end
            end
            x = x + 16;
            if x>=map_width*16 then
                x = 0;
                y = y + 16;
                if i==1 then
                    map_matrix[#map_matrix+1] = map_row;
                    map_row = {};
                else
                    over_matrix[#over_matrix+1] = over_row;
                    over_row = {};
                end
            end
        end
    end

    over_matrix_copy = deepcopy(over_matrix);
    map_matrix_copy = deepcopy(map_matrix);

    print("Assets Loaded");
end;