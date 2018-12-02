GameState = {
    -- x = 1,
    -- y = 1,
    -- map_x = 0,
    -- map_y = 0,
    -- map_tween = nil,
    map_x  = 1,
    map_y  = 1,
    map_tx = 1,
    map_ty = 1,
    -- map_tween = nil,
    player_x = 1280/2,
    player_y = 720/2,
    player_tx = 1280/2,
    player_ty = 720/2,
    player_tween = nil,
    player_state = -1, -- -1:CanMove 0:MovingPlayer 1:MovingMap
    player_shaking = false,
    player_shake = 0,
    player_shake_time = 0,
    player_side = 1,

    flashlight_force = 4,
    flashlight_tforce = 4,

    cards = {},
    card_hover = 0,
    card_open = 0,

    -- player_lock = false,
};

-- local CARD_W = 250;
-- local CARD_H = 400;
-- local CARD_P = 10;
-- local CARD_G = 5;
-- local CARD_DECO_PADDING = 14;

local SHAKE_T = .5;

local FLASHLIGHT_DEF_FORCE = 6;

local TILE_S = 8;

function GameState:init()
    self.cards[1] = Cards.diligitis;
    self.cards[2] = Cards.diligitis;
end

local CARD_W = 250;
local CARD_H = 400;
local CARD_PADDING = 10;
local CARD_ADDON_S = 10;
local CARD_GAP = 0;
local CARD_OUTLINE = 10;
local SAFE_PADDING = 10;

function GameState:draw()
    white();

    for i,map_batch in ipairs(map_batches) do
        -- print(i)
        love.graphics.draw(map_batch, 1280/2 - 8*TILE_S - 16*TILE_S*self.map_x, 720/2 - 8*TILE_S - 16*TILE_S*self.map_y, 0, TILE_S, TILE_S);
    end

    local player_x = self.player_x - 16 * TILE_S / 2;
    local player_y = self.player_y - 16 * TILE_S / 2;

    if self.player_shaking then
        local alpha = math.sin(self.player_shake_time/SHAKE_T*math.pi);
        player_x = player_x + math.cos(self.player_shake_time*(alpha*50))*3;
    end

    local xpoff = 0;

    if self.player_side==-1 then
        xpoff = 16*TILE_S;
    end


    black(0.2);
    love.graphics.ellipse("fill", player_x + TILE_S*16/2, player_y + TILE_S*16 - 20, 40, 20);
    white();
    love.graphics.draw(images.atlas, quads[13], player_x+xpoff, player_y, 0, TILE_S*self.player_side, TILE_S);

    shaders.flashlight:send("force", self.flashlight_force); -- Needs lerp!
    love.graphics.setShader(shaders.flashlight);
    love.graphics.draw(images.pixel, 0, 0, 0, 1280, 720);
    love.graphics.setShader();

    self.card_hover = 0;

    -- local card_count = #self.cards;
    -- local a = CARD_W*card_count;
    -- local b = a - CARD_W;

    for i,card in ipairs(self.cards) do
        self:drawCard(i*(CARD_W/2), 720, i);
    end

    for i,card in ipairs(self.cards) do
        self:drawCard(i*(CARD_W/2), 720, i);
    end

    if over_matrix[self.map_ty+1][self.map_tx+1]==4 then
        white();
        love.graphics.setFont(fonts.skullboy);
        love.graphics.printf("'E'\nPick card", player_x, player_y - 30, TILE_S * 16/2, "center", 0, 2, 2);
    end
end

function GameState:drawCard(x, y, idx)
    local lX = x - CARD_W/2;
    local lY = y - CARD_H/2;

    local text = self.cards[idx].name;
    local description = self.cards[idx].description;

    if collide(lX, lY, CARD_W, CARD_H, mouse_x, mouse_y) then
        self.card_hover = idx;
        local focus_gap = 25 + math.cos(love.timer.getTime()*10)*2;
        local focus_gap2 = 25 + math.sin(love.timer.getTime()*10)*2;
        local alpha = map(math.cos(love.timer.getTime()*7), -1, 1, .5, 1);
        
        color(0x7a09fa, alpha);
        love.graphics.polygon("fill", {
            lX, lY-CARD_GAP-focus_gap2,
            lX+CARD_W, lY-CARD_GAP-focus_gap,
            lX+CARD_W+CARD_GAP+focus_gap2, lY,
            lX+CARD_W+CARD_GAP+focus_gap, lY+CARD_H,
            lX+CARD_W, lY+CARD_H+CARD_GAP+focus_gap2,
            lX, lY+CARD_H+CARD_GAP+focus_gap,
            lX-CARD_GAP-focus_gap2, lY+CARD_H,
            lX-CARD_GAP-focus_gap, lY,
        });
    end

    black();
    love.graphics.rectangle("fill", lX - CARD_OUTLINE, lY - CARD_OUTLINE, CARD_W + CARD_OUTLINE*2, CARD_H + CARD_OUTLINE*2);
    color(0xf1f1f1);
    love.graphics.rectangle("fill", lX, lY, CARD_W, CARD_H);
    love.graphics.rectangle("fill", lX, lY, CARD_W, -CARD_GAP);
    love.graphics.rectangle("fill", lX, lY, -CARD_GAP, CARD_H);
    love.graphics.rectangle("fill", lX + CARD_W, lY, CARD_GAP, CARD_H);
    love.graphics.rectangle("fill", lX, lY + CARD_H, CARD_W, CARD_GAP);

    black(.08);
    love.graphics.polygon("fill", {
        lX + CARD_W + CARD_GAP, lY + CARD_H + CARD_GAP,
        lX + CARD_W + CARD_GAP, lY - CARD_GAP,
        lX - CARD_GAP, lY + CARD_H + CARD_GAP
    });
    
    color(0x5d5d5d);

    love.graphics.setLineWidth(3);
    love.graphics.setLineStyle("rough");
    love.graphics.rectangle("line", lX + CARD_PADDING, lY + CARD_PADDING, CARD_ADDON_S, CARD_ADDON_S);
    love.graphics.rectangle("line", lX + CARD_W - CARD_PADDING, lY + CARD_PADDING, -CARD_ADDON_S, CARD_ADDON_S);
    love.graphics.rectangle("line", lX + CARD_PADDING, lY + CARD_H - CARD_PADDING, CARD_ADDON_S, -CARD_ADDON_S);
    love.graphics.rectangle("line", lX + CARD_W - CARD_PADDING, lY + CARD_H - CARD_PADDING, -CARD_ADDON_S, -CARD_ADDON_S);
    love.graphics.rectangle("line", lX + CARD_PADDING + CARD_ADDON_S, lY + CARD_PADDING + CARD_ADDON_S, CARD_W - CARD_ADDON_S*4, CARD_H - CARD_ADDON_S*4);
    
    local safeW = CARD_W - CARD_ADDON_S*4 - SAFE_PADDING * 2;
    local safeX = lX + CARD_PADDING + CARD_ADDON_S + SAFE_PADDING;
    local safeY = lY + CARD_PADDING + CARD_ADDON_S + SAFE_PADDING;

    local cy = safeY+2;

    white();
    love.graphics.draw(images.atlas2, quads2[1], safeX+safeW/2, cy, 0, 6, 6, 16/2, 0);

    cy = cy + 6*16;
    
    love.graphics.setFont(fonts.skullboy);
    color(0x3d3d3d);
    love.graphics.printf(text, safeX, cy + 2, safeW/4, "center", 0, 4, 4);
    color(0x5d5d5d);
    love.graphics.printf(text, safeX, cy, safeW/4, "center", 0, 4, 4);
    local max_width, wrapped = fonts.skullboy:getWrap(text, safeW/4);
    love.graphics.setFont(fonts.square);
    color(0x5d5d5d);
    cy = cy + #wrapped * fonts.skullboy:getHeight()*4 + 20;
    love.graphics.printf(description, safeX, cy, safeW/2, "center", 0, 2, 2);
end

function GameState:centerPlayer()
    self.player_tx = 1280/2;
    self.player_ty = 720/2;
    -- self.map_tween = tween.new(1, GameState, {player_y = self.player_ty, map_y = self.map_ty}, "inQuart");
end

function GameState:update(dt)
    if self.player_tween then
        local completed = self.player_tween:update(dt);
        if completed then
            if self.player_state==0 then
                self.player_state = 1;
                self:centerPlayer();
                self.player_tween = tween.new(.5, GameState, {
                    player_x = self.player_tx,
                    player_y = self.player_ty,
                    map_x = self.map_tx,
                    map_y = self.map_ty,
                }, "inQuart");
            else
                self.player_state = -1;
            end
        end
    end

    if self.player_shaking then
        self.player_shake_time = self.player_shake_time + dt;
    end

    if self.player_shake_time>=SHAKE_T then
        self.player_shaking = false;
    end

    self.flashlight_force = lerp(self.flashlight_force, FLASHLIGHT_DEF_FORCE + math.random(5)*math.random(-1, 1), dt);
end

function GameState:playerShake()
    self.player_shaking = true;
    self.player_shake_time = 0;
end

function GameState:canWalk(x, y)
    print(y, x, map_matrix[y+1][x+1])
    return map_matrix[y+1][x+1]==10;
end

function GameState:mousepressed()
end

function GameState:keypressed(key)
    if self.player_state>=0 or self.player_shaking then
        return;
    end

    local moved = false;

    if key=="w" then
        -- self.y = self.y - 1;
        if self:canWalk(self.map_tx, self.map_ty - 1) then
            self.player_ty = self.player_ty - 16 * TILE_S;
            self.map_ty = self.map_ty - 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="s" then
        if self:canWalk(self.map_tx, self.map_ty + 1) then
            self.player_ty = self.player_ty + 16 * TILE_S;
            self.map_ty = self.map_ty + 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="a" then
        self.player_side = -1;
        if self:canWalk(self.map_tx - 1, self.map_ty) then
            self.player_tx = self.player_tx - 16 * TILE_S;
            self.map_tx = self.map_tx - 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="d" then
        self.player_side = 1;
        if self:canWalk(self.map_tx + 1, self.map_ty) then
            self.player_tx = self.player_tx + 16 * TILE_S;
            self.map_tx = self.map_tx + 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    end

    if moved then
        self.player_state = 0;
        self.player_tween = tween.new(.3, GameState, {
            player_y = self.player_ty,
            player_x = self.player_tx,
        }, "outQuart");
    end


    -- self:setMapPos(self:getMapX(self.x), self:getMapY(self.y));
end