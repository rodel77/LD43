GameState = {
    x = 1,
    y = 1,
};

local CARD_W = 250;
local CARD_H = 400;
local CARD_P = 10;

local TILE_S = 8;

function GameState:draw()
    white();
    love.graphics.draw(map_batch, 1280/2 - (self.x+.5) * 16 * TILE_S, 720/2 - (self.y+.5) * 16 * TILE_S, 0, TILE_S, TILE_S);
    love.graphics.draw(images.atlas, quads[13], 1280/2 - 16 * TILE_S / 2, 720/2 - 16 * TILE_S / 2, 0, TILE_S, TILE_S);

    shaders.flashlight:send("force", 7 + math.random()*2); -- Needs lerp!
    love.graphics.setShader(shaders.flashlight);
    love.graphics.draw(images.pixel, 0, 0, 0, 1280, 720);
    love.graphics.setShader();
    -- love.graphics.circle("fill", 1280/2, 720/2, 20);
    -- love.graphics.draw(images.atlas, quads[1]);
    -- love.graphics.draw(images.atlas, quads[2], 16);
    -- love.graphics.draw(images.atlas, quads.center, 1280/2, 720/2, 0, TILE_S, TILE_S, 16/2, 16/2);
    -- love.graphics.draw(images.atlas, quads.us, 1280/2, 720/2 - 16*TILE_S, 0, 8, 8, 16/2, 16/2);
    -- love.graphics.draw(images.atlas, quads.ulc, 1280/2 - 16*TILE_S, 720/2 - 16*TILE_S, 0, 8, 8, 16/2, 16/2);

    self:drawCard(1280/2, 720+CARD_H/2);
end

function GameState:drawCard(x, y)
    color(0xfff1f1f1);
    love.graphics.rectangle("fill", x-CARD_W/2, y-CARD_H, CARD_W, CARD_H, 10)
    color(0xffd1d1d1);
    love.graphics.setLineWidth(3);
    love.graphics.setLineStyle("rough");
    love.graphics.rectangle("line", x-CARD_W/2+CARD_P, y-CARD_H+CARD_P, CARD_W-CARD_P*2, CARD_H-CARD_P*2, 10)
end

function GameState:update(dt)

end

function GameState:keypressed(key)
    if key=="w" then
        self.y = self.y - 1;
    end
    if key=="s" then
        self.y = self.y + 1;
    end
end