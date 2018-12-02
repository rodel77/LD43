inspect = require "libs.inspect";
tween = require "libs.tween";
local loadAssets = require "src.loader";
require "src.cards";
require "src.utils";
require "src.state.game";
CScreen = require "libs.cscreen";

settings = {
    hotswap = true;
};
local state = GameState;

mouse_x, mouse_y = 0;

function love.load()
    CScreen.init(1280, 720, true);

    loadAssets();

    if state.init then
        state:init();
    end
end

function love.draw()
    CScreen.apply();

    -- color(0xea323c);
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

    mouse_x, mouse_y = love.mouse.getPosition();
    mouse_x, mouse_y = CScreen.project(mouse_x, mouse_y);
end

function love.keypressed(key)
    if key=="escape" then
        love.event.quit();
    end

    if state.keypressed then
        state:keypressed(key);
    end
end

function love.mousepressed()
    if state.mousepressed then
        state:mousepressed();
    end
end

function love.resize(w, h)
    CScreen.update(w, h);
end