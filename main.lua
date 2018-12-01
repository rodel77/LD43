inspect = require "libs.inspect";
local loadAssets = require "src.loader";
require "src.utils";
require "src.state.game";
CScreen = require "libs.cscreen";

settings = {
    hotswap = true;
};
local state = GameState;

function love.load()
    CScreen.init(1280, 720, true);

    loadAssets();
end

function love.draw()
    CScreen.apply();

    black();
    love.graphics.rectangle("fill", 0, 0, 1280, 720);

    if state.draw then
        state:draw();
    end

    CScreen.cease();
end

function love.update(dt)
    if settings.hotswap then
        require("libs.lurker").update();
    end

    if state.update then
        state:update(dt);
    end
end

function love.keypressed(key)
    if key=="escape" then
        love.event.quit();
    end

    if state.keypressed then
        state:keypressed(key);
    end
end

function love.resize(w, h)
    CScreen.update(w, h);
end