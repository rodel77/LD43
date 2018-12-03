MenuState = {
    inter_tween = nil,
    start_tween = nil,
    play_hover = false,
    play_alpha = 0,

    title_y = -200,
    card_off = 720,

    music_tween = nil,

    music_slider = 0,
    sound_slider = 0,
};

function MenuState:init()
    self.start_tween = tween.new(10, MenuState, {
        title_y = 0,
        card_off = 0,
    }, "outQuint");

    self.music_tween = tween.new(5, music, {
        volume = 0.5,
    })
end

function MenuState:draw()
    -- print(inspect(fonts.lantern))
    white();
    love.graphics.setFont(fonts.lantern);
    color(0xffc825);
    love.graphics.print("Pecto", 1280/2, 124 + math.sin(love.timer.getTime())*10 + self.title_y, math.cos(love.timer.getTime())*.07, 8, 8, fonts.lantern:getWidth("Pecto")/2, fonts.lantern:getHeight()/2);
    color(0xffeb57);
    love.graphics.print("Pecto", 1280/2, 120 + math.sin(love.timer.getTime())*10 + self.title_y, math.cos(love.timer.getTime())*.07, 8, 8, fonts.lantern:getWidth("Pecto")/2, fonts.lantern:getHeight()/2);

    white();
    local oldPH = self.play_hover;
    self.play_hover = false
    if collide(1280/2 - CARD_W/2, 720/2 - CARD_H/2 + 70 + math.sin(love.timer.getTime()+math.pi/2)*10 + self.card_off, CARD_W, CARD_H, mouse_x, mouse_y) then
        self.play_hover = true
    end

    if oldPH~=self.play_hover then
        self.inter_tween = tween.new(1, MenuState, {
            play_alpha = self.play_hover and 1 or 0,
        }, self.player_hover and "inQuint" or "outQuint");
    end

    love.graphics.push();
    love.graphics.translate(1280/2, 720/2 + 70 + math.sin(love.timer.getTime()+math.pi/2)*10 + self.card_off);
    love.graphics.scale(1 + (.05*self.play_alpha))
    love.graphics.rotate(math.cos(love.timer.getTime()*4*self.play_alpha)*.02*self.play_alpha)

    self:drawCard(0, 0, {
        name = "Play",
        description = "",
        tier = 1,
    }, true, self.play_alpha)
    love.graphics.pop();

    white();
    love.graphics.setFont(fonts.skullboy)
    love.graphics.print("Created for LD43\nin 48 hours\nBy @therodel77", 10, 720 - 10, 0, 2, 2, 0, fonts.skullboy:getHeight()*3);

    self.music_slider = 0;
    self.sound_slider = 0;


    local msc = "Music: "..math.floor(music.volume*100).."%";
    local sds = "Sounds: "..math.floor(sounds.volume*100).."%";

    love.graphics.print(msc, (1280/3)*2.3 - fonts.skullboy:getWidth(msc)/2, 720/2 - 30, 0, 3, 3);
    love.graphics.print(sds, (1280/3)*2.3 - fonts.skullboy:getWidth(sds)/2, 720/2 + 30, 0, 3, 3);

    local x = (1280/3)*2.3 - fonts.skullboy:getWidth(msc)/2 - 20;
    local y = 720/2 - 30;
    local w = 14;
    local h = fonts.skullboy:getHeight()*3 - 9;

    if collide(x, y, w, h, mouse_x, mouse_y) then
        color(0xffeb57);
        self.music_slider = -1;
    end

    love.graphics.print("<", x, y, 0, 3, 3);
    white();

    x = (1280/3)*2.3 - fonts.skullboy:getWidth(msc)/2 + fonts.skullboy:getWidth(msc)*3 + 15; -- help

    if collide(x, y, w, h, mouse_x, mouse_y) then
        color(0xffeb57);
        self.music_slider = 1;
    end
    love.graphics.print(">", x, y, 0, 3, 3);
    white();

    x = (1280/3)*2.3 - fonts.skullboy:getWidth(sds)/2 - 20;
    y = 720/2 + 30;
    w = 14;
    h = fonts.skullboy:getHeight()*3 - 9;

    if collide(x, y, w, h, mouse_x, mouse_y) then
        self.sound_slider = -1;
        color(0xffeb57);
    end
    love.graphics.print("<", x, y, 0, 3, 3);
    white();

    x = (1280/3)*2.3 - fonts.skullboy:getWidth(sds)/2 + fonts.skullboy:getWidth(sds)*3 + 15;

    if collide(x, y, w, h, mouse_x, mouse_y) then
        self.sound_slider = 1;
        color(0xffeb57);
    end
    love.graphics.print(">", x, y, 0, 3, 3);
    white();

    -- love.graphics.printf(msc, (1280/3)*2, 720/2-20, 1280/6, "center", 0, 2, 2, 0, fonts.skullboy:getHeight()/2);
    -- love.graphics.printf(sds, (1280/3)*2, 720/2+20, 1280/6, "center", 0, 2, 2, 0, fonts.skullboy:getHeight()/2);
end

function MenuState:update(dt)
    if self.inter_tween then
        self.inter_tween:update(dt);
    end

    if self.start_tween then
        self.start_tween:update(dt);
    end

    if self.music_tween then
        self.music_tween:update(dt);
    end
end

function MenuState:mousepressed()
    if self.play_hover then
        GameState:init();
        state = GameState;
        sounds.dead:play();
    end
    if self.music_slider~=0 or self.sound_slider~=0 then
        if self.music_slider~=0 then
            self.music_tween = nil;
        end
        sounds.player:play();
    end

    music.volume = math.max(0, math.min(1, music.volume + self.music_slider*.1));
    sounds.volume = math.max(0, math.min(1, sounds.volume + self.sound_slider*.1));
end

function MenuState:drawCard(x, y, card, focus, bright_mult)
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
    -- love.graphics.draw(images.atlas2, quads2[card.image], safeX+safeW/2, cy, 0, 6, 6, 16/2, 0);

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

    if card.tier==1 then
        -- description = description.."\n\n20 Gems to Upgrade\n\n37 Gems to + Upgrade"
    end

    love.graphics.printf(description, safeX, cy, safeW/2, "center", 0, 2, 2);
end