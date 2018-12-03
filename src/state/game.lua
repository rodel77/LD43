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
    player_heal = 100,
    player_heald = 100,
    player_gems = 0,
    player_dgems = 0,

    flashlight_force = 4,
    flashlight_tforce = 4,

    cards = {},
    card_hover = 0,
    card_open = 0,

    upgrade_alpha = 1,
    upgrade_tween = nil,

    cards_y = 720,
    cards_lock = false,
    card_sx = 0,
    card_sy = 0,
    card_s = nil,
    card_disenchant = false,
    menu_hover = 0,
    cards_tween = nil,
    last_y = 720,
    last_tween = nil,

    disenchant_time = 0,

    hover_x = 0,
    hover_y = 720,
    hover_tween = nil,

    gems_tween = nil,

    adjacent_monster = nil,
    monster_x = 0,
    monster_y = 0,

    damage_state = 0,
    damage_tween = nil,

    heal_tween = nil,

    monster_lose = 0,

    -- player_lock = false,
};

stateCopy = deepcopy(GameState);

-- local CARD_W = 250;
-- local CARD_H = 400;
-- local CARD_P = 10;
-- local CARD_G = 5;
-- local CARD_DECO_PADDING = 14;

local SHAKE_T = .5;

local FLASHLIGHT_DEF_FORCE = 6;

local TILE_S = 8;

local function isMonster(monster)
    return type(monster)=="table" and monster.heal;
end

function GameState:init()
    for i=1,5 do
        -- self.cards[i] = Cards.diligitis;
    end
    -- self.cards[1] = Cards.diligitis;
end

local CARD_W = 250;
local CARD_H = 400;
local CARD_PADDING = 10;
local CARD_ADDON_S = 10;
local CARD_GAP = 0;
local CARD_OUTLINE = 10;
local MAX_CARDS = 17;
local MAX_SPACE = CARD_W/4;
local SAFE_PADDING = 10;
local MAX_HEAL = 100;

local TIER1_GEMS = 20;
local TIER2_GEMS = 34;

function GameState:resetState()
    over_matrix = over_matrix_copy;
    map_matrix = map_matrix_copy;
    GameState = stateCopy;
end

function GameState:draw()
    white();



    love.graphics.draw(map_batches[1], 
    math.floor(1280/2 - 8*TILE_S - 16*TILE_S*self.map_x), 
    math.floor(720/2 - 8*TILE_S - 16*TILE_S*self.map_y), 0, TILE_S, TILE_S);

    for i,row in ipairs(over_matrix) do
        for j,el in ipairs(row) do
            if el~=0 then
                local monster = false;
                local mx = math.floor(1280/2 - 8*TILE_S - 16*TILE_S*(self.map_x-j+1));
                local my = math.floor(720/2 - 8*TILE_S - 16*TILE_S*(self.map_y-i+1));
                local side = 1;

                if isMonster(el) then
                    monster = true;

                    if mx>700 then
                        side = -1;
                    end
                    black(0.2);
                    love.graphics.ellipse("fill", mx + TILE_S*16/2, my + TILE_S*16 - 20, 40, 20);
                    white();
                    love.graphics.draw(images.atlas, quads[el.id], 
                    mx + (side==-1 and 16*TILE_S or 0), 
                    my, 0, TILE_S*side, TILE_S);
                    if el.id~=16 then
                        black();
                        love.graphics.rectangle("fill", mx + TILE_S*10/2 - 5, my + TILE_S*16 - 5, TILE_S*7 + 10, 10 + 10);
                        color(1-el.heald/MAX_HEAL, el.heald/MAX_HEAL, 0);
                        love.graphics.rectangle("fill", mx + TILE_S*10/2, my + TILE_S*16, math.max(0, (el.heald/MAX_HEAL)*(TILE_S*7)), 10);
                        black(0.2);
                        love.graphics.rectangle("fill", mx + TILE_S*10/2, my + TILE_S*16 + 5, math.max(0, (el.heald/MAX_HEAL)*(TILE_S*7)), 5); 
                    end
                else
                    white();
                    love.graphics.draw(images.atlas, quads[el], 
                    mx + (side==-1 and 16*TILE_S or 0), 
                    my, 0, TILE_S*side, TILE_S);
                end
            end
        end
    end

    local player_x = math.floor(self.player_x - 16 * TILE_S / 2);
    local player_y = math.floor(self.player_y - 16 * TILE_S / 2);

    if self.player_shaking then
        local alpha = math.sin(self.player_shake_time/SHAKE_T*math.pi);
        player_x = player_x + math.cos(self.player_shake_time*(alpha*50))*3;
    end

    local xpoff = 0;

    if isMonster(over_matrix[self.map_ty+1][self.map_tx+2]) then
        self.player_side = 1;
    end

    if isMonster(over_matrix[self.map_ty+1][self.map_tx]) then
        self.player_side = -1;
    end

    if self.player_side==-1 then
        xpoff = 16*TILE_S;
    end


    black(0.2);
    love.graphics.ellipse("fill", player_x + TILE_S*16/2, player_y + TILE_S*16 - 20, 40, 20);
    black();
    love.graphics.rectangle("fill", player_x + TILE_S*10/2 - 5, player_y + TILE_S*16 - 5, TILE_S*7 + 10, 10 + 10);
    color(1-self.player_heald/MAX_HEAL, self.player_heald/MAX_HEAL, 0);
    love.graphics.rectangle("fill", player_x + TILE_S*10/2, player_y + TILE_S*16, (math.max(0, self.player_heald/MAX_HEAL))*(TILE_S*7), 10);
    black(0.2);
    love.graphics.rectangle("fill", player_x + TILE_S*10/2, player_y + TILE_S*16 + 5, (math.max(0, self.player_heald/MAX_HEAL))*(TILE_S*7), 5);
    white();
    love.graphics.draw(images.atlas, quads[13], player_x+xpoff, player_y, 0, TILE_S*self.player_side, TILE_S);

    shaders.flashlight:send("force", self.flashlight_force); -- Needs lerp!
    love.graphics.setShader(shaders.flashlight);
    love.graphics.draw(images.pixel, 0, 0, 0, 1280, 720);
    love.graphics.setShader();

    if over_matrix[self.map_ty+1][self.map_tx+1]==4 then
        white();
        love.graphics.setFont(fonts.skullboy);
        love.graphics.printf("'E'\nPick card", player_x, player_y - 30, TILE_S * 16/2, "center", 0, 2, 2);
    end

    local sy = self.map_ty+1;
    local sx = self.map_tx+2;

    local withMonster = isMonster(over_matrix[sy][sx]);

    if not withMonster then
        sy = self.map_ty+1;
        sx = self.map_tx;
        withMonster = isMonster(over_matrix[sy][sx]);
    end

    if not withMonster then
        sy = self.map_ty+2;
        sx = self.map_tx+1;
        withMonster = isMonster(over_matrix[sy][sx]);
    end

    if not withMonster then
        sy = self.map_ty;
        sx = self.map_tx+1;
        withMonster = isMonster(over_matrix[sy][sx]);
    end

    self.adjacent_monster = nil;
    self.monster_x = 0;
    self.monster_y = 0;
    
    if withMonster then
        white();
        love.graphics.setFont(fonts.skullboy);
        
        self.monster_x = sx;
        self.monster_y = sy;
        self.adjacent_monster = over_matrix[sy][sx];

        if self.adjacent_monster.id==16 then
            love.graphics.printf("'E'\nSpend 30\nGet a card", player_x - TILE_S * 16/2, player_y - 40, TILE_S * 16, "center", 0, 2, 2);
        else
            love.graphics.printf("'E'\nAttack\n"..self.adjacent_monster.name, player_x - TILE_S * 16/2, player_y - 40, TILE_S * 16, "center", 0, 2, 2);
        end
    end

    local old_hover = self.card_hover;

    self.card_hover = 0;

    -- local card_count = #self.cards;
    -- local a = CARD_W*card_count;
    -- local b = a - CARD_W;


    -- love.graphics.rectangle("fill", 0, player_y+16*TILE_S, 1280, 720/2)

    local cx = CARD_W/2;
    -- local spacing = map(#self.cards, 2, MAX_CARDS, CARD_W, 30);
    -- print(#self.cards, 2, MAX_CARDS, CARD_W, MAX_SPACE, spacing)

    spacing = MAX_SPACE;

    for i,card in ipairs(self.cards) do
        local lX = cx - CARD_W/2;
        local lY = self.cards_y;
        
        if i==#self.cards then
            spacing = CARD_W + CARD_OUTLINE;
            if self.last_tween then
                lY = self.last_y;
            end
        end
        
        if collide(lX, 720-CARD_H/2, spacing-CARD_OUTLINE/2, CARD_H, mouse_x, mouse_y) and self.card_hover == 0 and not self.cards_lock then
            self.card_hover = i;
            self.hover_x = cx;
            lY = self.hover_y;
            spacing = CARD_W
        else
            spacing = MAX_SPACE;
            -- lY = math.max(lY, player_y + TILE_S*16/2 + 720/2);
        end

        self:drawCard(cx, lY, self.cards[i], self.card_hover==i);
        -- color(1, 0, 0, .3);
        -- if collide(lX, 720-CARD_H/2-100, spacing-CARD_OUTLINE, CARD_H, mouse_x, mouse_y) then
        --     color(1, 1, 0, .3);
        -- end
        -- love.graphics.rectangle("fill", lX, 720-CARD_H/2-100, spacing-CARD_OUTLINE, CARD_H);
        -- white();

        cx = cx + spacing;
    end

    local BUTTON_W = 270;
    local BUTTON_H = 60;

    if self.card_s then
        self.menu_hover = 0;
        
        local yOff = 160;


        -- self:drawCard(0, 0, self.card_s, false, map(math.sin(love.timer.getTime()*5), -1, 1, 1, 5));
        if self.card_disenchant then
            love.graphics.push();
            love.graphics.translate(self.card_sx, self.card_sy);
            love.graphics.stencil(function()
                love.graphics.rectangle("fill", -10, -720/2, -1270/2, 720);
                love.graphics.rectangle("fill", 10, -720/2, 1270/2, 720);
            end, "replace", 1);
            love.graphics.setStencilTest("greater", 0);
            self:drawCard(0, 0, self.card_s, false);
            love.graphics.setStencilTest();
            love.graphics.pop();
        else
            love.graphics.push();
            love.graphics.translate(self.card_sx, self.card_sy + math.sin(love.timer.getTime()*3*self.upgrade_alpha)*5*self.upgrade_alpha);
            love.graphics.rotate(math.cos(love.timer.getTime()*4*self.upgrade_alpha)*.02*self.upgrade_alpha);
            self:drawCard(0, 0, self.card_s, true, math.abs(math.sin(love.timer.getTime())) + 1 * self.upgrade_alpha^5);
            love.graphics.pop();
        end

        -- love.graphics.stencil(function()
        --     love.graphics.rectangle("fill", 0, -720/2, 1270/2, 720);
        -- end, "replace", 1);
        -- love.graphics.setStencilTest("greater", 0);
        -- self:drawCard(0, 0, self.card_s, false, math.abs(math.sin(love.timer.getTime())) + 1);
        -- love.graphics.setStencilTest();

        -- love.graphics.stencil(function()
        --     love.graphics.rectangle("fill", -1280/2, -720/2, 1270/2, 720);
        -- end, "replace", 1);
        -- love.graphics.setStencilTest("greater", 0);
        -- self:drawCard(0, 0, self.card_s, false, math.abs(math.sin(love.timer.getTime())) + 1);
        -- love.graphics.setStencilTest();

        self.menu_hover = 0;

        if not self.card_disenchant and not self.upgrade_tween then

            love.graphics.setFont(fonts.skullboy);
            local bX = 1280/2-BUTTON_W/2 - 150;
            local bY = 720-yOff;
            black();
            love.graphics.rectangle("fill", bX-5, bY-5, BUTTON_W+10, BUTTON_H+10)
            color(0xea323c);
            love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
            color(0xc42430);
            love.graphics.polygon("fill", {
                bX+BUTTON_W, bY,
                bX+BUTTON_W, bY+BUTTON_H,
                bX, bY+BUTTON_H,
            });
            white();
            love.graphics.print("Cancel", bX + BUTTON_W/2, bY + BUTTON_H/2 - fonts.skullboy:getHeight()*1.5, 0, 4, 4, fonts.skullboy:getWidth("Cancel")/2);

            if collide(bX-5, bY-5, BUTTON_W+10, BUTTON_H+10, mouse_x, mouse_y) then
                color(0xffeb57, .3);
                self.menu_hover = 1;
                love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                white();
            end

            bX = 1280/2-BUTTON_W/2 + 150;
            bY = 720-yOff;
            black();
            love.graphics.rectangle("fill", bX-5, bY-5, BUTTON_W+10, BUTTON_H+10)
            color(0x3003d9);
            love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
            color(0x0c0293);
            love.graphics.polygon("fill", {
                bX+BUTTON_W, bY,
                bX+BUTTON_W, bY+BUTTON_H,
                bX, bY+BUTTON_H,
            });
            white();
            love.graphics.print("Disenchant", bX + BUTTON_W/2, bY + BUTTON_H/2 - fonts.skullboy:getHeight()*1.5, 0, 4, 4, fonts.skullboy:getWidth("Disenchant")/2);

            if collide(bX-5, bY-5, BUTTON_W+10, BUTTON_H+10, mouse_x, mouse_y) then
                color(0xffeb57, .3);
                self.menu_hover = 2;
                love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                white();
            end

            if self.card_s.tier==1 then
                bX = 1280/2-BUTTON_W/2 - 150;
                bY = 720-80;
                black();
                love.graphics.rectangle("fill", bX-5, bY-5, BUTTON_W+10, BUTTON_H+10)
                color(0x0098dc);
                love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                color(0x0069aa);
                love.graphics.polygon("fill", {
                    bX+BUTTON_W, bY,
                    bX+BUTTON_W, bY+BUTTON_H,
                    bX, bY+BUTTON_H,
                });
                white();
                love.graphics.print("Upgrade", bX + BUTTON_W/2, bY + BUTTON_H/2 - fonts.skullboy:getHeight()*1.5, 0, 4, 4, fonts.skullboy:getWidth("Upgrade")/2);

                if self.player_gems>=20 and collide(bX-5, bY-5, BUTTON_W+10, BUTTON_H+10, mouse_x, mouse_y) then
                    color(0xffeb57, .3);
                    self.menu_hover = 3;
                    love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                    white();
                end
                
                if self.player_gems<20 then
                    black(.5);
                    love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                end
            end

            if self.card_s.tier==2 then
                bX = 1280/2-BUTTON_W/2;
            else
                bX = 1280/2-BUTTON_W/2 + 150;
            end
            bY = 720-80;
            black();
            love.graphics.rectangle("fill", bX-5, bY-5, BUTTON_W+10, BUTTON_H+10)
            color(0x5ac54f);
            love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
            color(0x33984b);
            love.graphics.polygon("fill", {
                bX+BUTTON_W, bY,
                bX+BUTTON_W, bY+BUTTON_H,
                bX, bY+BUTTON_H,
            });
            white();
            love.graphics.print("Use", bX + BUTTON_W/2, bY + BUTTON_H/2 - fonts.skullboy:getHeight()*1.5, 0, 4, 4, fonts.skullboy:getWidth("Use")/2);

            if collide(bX-5, bY-5, BUTTON_W+10, BUTTON_H+10, mouse_x, mouse_y) then
                color(0xffeb57, .3);
                self.menu_hover = 4;
                love.graphics.rectangle("fill", bX, bY, BUTTON_W, BUTTON_H)
                white();
            end
        end
        -- love.graphics.print("Cancel", bX + BUTTON_W/2, bY + BUTTON_H/2, 0, 4, 4, fonts.skullboy:getWidth("Cancel")/2, fonts.skullboy:getHeight()/2);
    end

    if old_hover~=self.card_hover then
        self.hover_y = 720;
        if self.card_hover == 0 then
            self.hover_x = 0;
            self.hover_tween = nil;
        else
            self.hover_tween = tween.new(.5, GameState, {
                hover_y = 720-CARD_H/2,
            }, "outQuint");
        end
    end

    white();
    love.graphics.draw(images.atlas, quads[5], 10, 10, 0, 4, 4)
    love.graphics.setFont(fonts.skullboy)
    color(0x00cdf9);
    love.graphics.print("GEMS: "..math.floor(self.player_dgems), 10, 10 + 16*4 + 7, 0, 2, 2);

    
    if self.player_heald<=0 then
        color(0x891e2b);
        love.graphics.rectangle("fill", 0, 0, 1280, 720)
        white();
        love.graphics.printf("You died and since I didn't planned this at the start\nand there are more than 2,500 lines of code\n(and a lot of chaos)\nyou would have to restart the game.\n\nSorry", 0, 720/2, 1280/4, "center", 0, 4, 4, 0, fonts.skullboy:getHeight()*5/2)
    end

    -- for i,card in ipairs(self.cards) do
    --     self:drawCard(i*(CARD_W/2), 720, i);
    -- end
end

function GameState:drawCard(x, y, card, focus, bright_mult)
    local lX = x - CARD_W/2;
    local lY = y - CARD_H/2;
    bright_mult = bright_mult or 1;

    local text = card.name;
    local description = card.description;

    if focus then
        local focus_gap = 25*bright_mult + math.cos(love.timer.getTime()*10)*2;
        local focus_gap2 = 25*bright_mult + math.sin(love.timer.getTime()*10)*2;
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
    if card.tier==1 then
    else
        -- color(0xfffb87);
    end
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
    
    if card.tier==1 then
        color(0x5d5d5d);
    else
        color(0xffa214);
    end

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
    love.graphics.draw(images.atlas2, quads2[card.image], safeX+safeW/2, cy, 0, 6, 6, 16/2, 0);

    cy = cy + 6*16;
    
    love.graphics.setFont(fonts.skullboy);
    local max_width, wrapped = fonts.skullboy:getWrap(text, safeW/4);
    local font_size = 4;
    if #wrapped>1 then
        font_size = 3;
    end

    if card.tier==1 then
        color(0x3d3d3d);
    else
        color(0xffc825);
    end
    love.graphics.printf(text, safeX, cy + 2, safeW/font_size, "center", 0, font_size, font_size);
    if card.tier==1 then
        color(0x5d5d5d);
    else
        color(0xffa214);
    end
    love.graphics.printf(text, safeX, cy, safeW/font_size, "center", 0, font_size, font_size);
    local max_width, wrapped = fonts.skullboy:getWrap(text, safeW/4);
    love.graphics.setFont(fonts.square);
    if card.tier==1 then
        color(0x5d5d5d);
    else
        color(0xffa214);
    end
    cy = cy + #wrapped * fonts.skullboy:getHeight()*4 + 20;

    description = description.."\n\n"..(card.tier==1 and TIER1_GEMS or TIER2_GEMS).." Gems on Disenchant";

    if card.tier==1 then
        description = description.."\n\n20 Gems to Upgrade"
    end

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
                self.player_tween = tween.new(.3, GameState, {
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

    if self.card_disenchant then
        self.disenchant_time = self.disenchant_time + dt;

        if self.disenchant_time>1 then
            self:setGems(self.player_gems + (self.card_s.tier==1 and TIER1_GEMS or TIER2_GEMS));
            self.card_disenchant = false;
            self.card_s = nil;
            self.cards_lock = false;
            self.cards_tween = tween.new(.5, GameState, {
                cards_y = 720,
            }, "outQuint");
        end
    end

    if self.player_shaking then
        self.player_shake_time = self.player_shake_time + dt;
    end

    if self.player_shake_time>=SHAKE_T then
        self.player_shaking = false;
    end

    if self.hover_tween then
        self.hover_tween:update(dt);
    end

    if self.cards_tween then
        self.cards_tween:update(dt);
    end

    if self.upgrade_tween then
        local completed = self.upgrade_tween:update(dt);
        sounds.upgrade:play();
        if completed then
            sounds.upgrade_finish:play();
            self.card_s = chance50() and Cards[self.card_s.ref] or getRandomT1(self.card_s);
            self.upgrade_tween = nil;
            self.cards_lock = false;
        end
    end

    if self.gems_tween then
        local completed = self.gems_tween:update(dt);

        sounds.click:play();

        if completed then
            self.gems_tween = nil;
        end
    end

    if self.last_tween then
        local completed = self.last_tween:update(dt);
        if completed then
            self.last_tween = nil;
        end
    end

    if self.damage_tween then
        local completed = self.damage_tween:update(dt);
        if completed then
            self.damage_tween = nil;

            if self.damage_state=="monster" then
                if self.adjacent_monster.heal>0 then
                    if self.monster_lose>0 then
                        self.monster_lose = self.monster_lose-1;
                        sounds.no:play();
                        self.damage_state = 0;
                    else
                        self.damage_state = "player";
                        
                        self.player_heal = self.player_heal - 8;
                        
                        sounds.player:play();
                        self.heal_tween = tween.new(.5, GameState, {
                            player_heald = self.player_heal,
                        });
                    end
                end
            end
        end
    end

    if self.heal_tween then
        local completed = self.heal_tween:update(dt);

        if completed then
            self.heal_tween = nil;

            if self.damage_state=="player" then
                if self.player_heal>0 then
                    self.damage_state = 0;
                else
                    -- YOU LOSE!
                end
            end
        end
    end

    self.flashlight_force = lerp(self.flashlight_force, FLASHLIGHT_DEF_FORCE + math.random(5)*math.random(-1, 1), dt);
end

function GameState:setGems(gems)
    self.player_gems = gems;
    self.gems_tween = tween.new(1, GameState, {
        player_dgems = self.player_gems,
    });
end

function GameState:playerShake()
    self.player_shaking = true;
    self.player_shake_time = 0;
end

function GameState:canWalk(x, y)
    return map_matrix[y+1][x+1]==10 and not isMonster(over_matrix[y+1][x+1]);
end

function GameState:mousepressed()
    if self.card_hover~=0 then
        local card = table.remove(self.cards, self.card_hover);
        self.card_sx = self.hover_x;
        self.card_sy = self.hover_y;
        self.card_s = card;
        self.card_hover = 0;
        self.cards_lock = true;
        sounds.see:play();
        self.cards_tween = tween.new(1, GameState, {
            cards_y = 720+CARD_W,
            card_sx = 1280/2,
            card_sy = 720/2-60,
        }, "inQuint");
    end

    if self.card_s then
        if self.menu_hover==1 then
            self:lastFeedback();
            table.insert(self.cards, self.card_s);
            self.card_s = nil;
            self.cards_lock = false;
            sounds.unsee:play();
            self.upgrade_alpha = 1;
            self.cards_tween = tween.new(.5, GameState, {
                cards_y = 720,
            }, "outQuint");
        elseif self.menu_hover==2 then
            self.upgrade_alpha = 1;
            self.card_disenchant = true;
            self.disenchant_time = 0;
            sounds.disenchant:play();
        elseif self.menu_hover==3 then
            self.upgrade_alpha = 1;
            self:setGems(self.player_gems - 20);
            self.upgrade_tween = tween.new(2, GameState, {
                upgrade_alpha = 2,
            }, "outQuint");
        elseif self.menu_hover==4 then
            self.card_s:use();
            self.card_s = nil;
            self.cards_lock = false;
            self.upgrade_alpha = 1;
            sounds.unsee:play();
            self.cards_tween = tween.new(.3, GameState, {
                cards_y = 720,
            }, "outQuint");
        end

        self.menu_hover = 0;
    end
end

function GameState:lastFeedback()
    self.last_y = 720+CARD_W+20;
    self.last_tween = tween.new(1, GameState, {
        last_y = 720,
    }, "inQuint");
end

function GameState:randomCard()
    return getRandomT1();
end

function GameState:keypressed(key)
    if self.player_state>=0 or self.player_shaking or self.card_s or self.damage_state~=0 then
        return;
    end
    
    local moved = false;
    
    if key=="y" then
        self:resetState();
    end

    if key=="e" then
        if over_matrix[self.map_ty+1][self.map_tx+1]==4 then
            over_matrix[self.map_ty+1][self.map_tx+1] = 0;
            table.insert(self.cards, self:randomCard());
            self:lastFeedback();
            sounds.pick:play();
        elseif self.adjacent_monster then
            if self.adjacent_monster.id==16 then
                if self.player_gems>=30 then
                    sounds.buy:play();
                    self:setGems(self.player_gems - 30);
                    table.insert(self.cards, self:randomCard());
                    self:lastFeedback();
                else
                    sounds.no:play();
                end
            else
                sounds.monster:play();
                self.adjacent_monster.heal = self.adjacent_monster.heal - 15;

                if self.adjacent_monster.heal<=0 then
                    sounds.dead:play();
                    over_matrix[self.monster_y][self.monster_x] = 4;
                    self.monster_lose = 0;
                else
                    self.damage_state = "monster";
                    self.damage_tween = tween.new(.3, self.adjacent_monster, {
                        heald = self.adjacent_monster.heal,
                    }, "outQuint");
                end
            end
        end
    end

    if key=="w" or key=="up" then
        -- self.y = self.y - 1;
        if self:canWalk(self.map_tx, self.map_ty - 1) then
            self.player_ty = self.player_ty - 16 * TILE_S;
            self.map_ty = self.map_ty - 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="s" or key=="down" then
        if self:canWalk(self.map_tx, self.map_ty + 1) then
            self.player_ty = self.player_ty + 16 * TILE_S;
            self.map_ty = self.map_ty + 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="a" or key=="left" then
        self.player_side = -1;
        if self:canWalk(self.map_tx - 1, self.map_ty) then
            self.player_tx = self.player_tx - 16 * TILE_S;
            self.map_tx = self.map_tx - 1;
            moved = true;
        else
            self:playerShake();
            return;
        end
    elseif key=="d" or key=="right" then
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
        sounds.move:play();
        self.player_state = 0;
        self.player_tween = tween.new(.3, GameState, {
            player_y = self.player_ty,
            player_x = self.player_tx,
        }, "outQuart");
    end


    -- self:setMapPos(self:getMapX(self.x), self:getMapY(self.y));
end