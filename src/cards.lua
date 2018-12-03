local Card = {
    name = "Pectofined",
    description = "Literally nothing.",
    image = 1,
};

function Card:create(o)
    o = o or {};
    setmetatable(o, {__index = Card});
    return o;
end

function Card:use()

end

Cards = {
    diligitis = Card:create{
        name = "Diligitis",
        description = "50%: Max heal\n50%: Lose most of your heal",
        ref = "vitae",
        tier = 1,
        image = 1,
        use = function()
            GameState.player_heal = chance50() and 100 or 15;
            GameState.heal_tween = tween.new(1, GameState, {
                player_heald = GameState.player_heal,
            }, "outQuint");
        end
    };
    rursus = Card:create{
        name = "Rursus",
        description = "50%: An enemy lose 1 turn\n50%: An enemy lose 5 turns",
        ref = "exspectans",
        tier = 1,
        image = 5,
        use = function()
            if chance50() then
                GameState.monster_lose = 1;
            else
                GameState.monster_lose = 5;
            end
        end
    };
    exspectans = Card:create{
        name = "Exspectans",
        description = "An enemy lose 6 turn",
        ref = "rursus",
        tier = 2,
        image = 6,
        use = function()
            GameState.monster_lose = 6;
        end
    };
    sacrificium = Card:create{
        name = "Sacrifis",
        description = "50%: Lose all your cards\n50%: Get 5 cards",
        ref = "sacrificium2",
        tier = 1,
        image = 4,
        use = function()
            if chance50() then
                sounds.no:play();
                GameState.cards = {};
            else
                sounds.buy:play();
                for i=1,4 do
                    GameState.cards[#GameState.cards+1] = getRandomT1();
                end
                GameState.cards[#GameState.cards+1] = getRandomT2();
            end
            -- GameState.player_heal = chance50() and 100 or 15;
            -- GameState.heal_tween = tween.new(1, GameState, {
            --     player_heald = GameState.player_heal,
            -- }, "outQuint");
        end
    };
    sacrificium2 = Card:create{
        name = "Sacrifis ll",
        description = "10%: Lose all your cards\n90%: Get 5 cards",
        ref = "sacrificium",
        tier = 2,
        image = 3,
        use = function()
            if chance20() then
                sounds.no:play();
                GameState.cards = {};
            else
                sounds.buy:play();
                for i=1,4 do
                    GameState.cards[#GameState.cards+1] = getRandomT1();
                end
                GameState.cards[#GameState.cards+1] = getRandomT2();
            end
        end
    };
    vitae = Card:create{
        name = "Vitae",
        description = "Max your heal",
        ref = "diligitis",
        tier = 2,
        image = 2,
        use = function()
            GameState.player_heal = 100;
            GameState.heal_tween = tween.new(1, GameState, {
                player_heald = GameState.player_heal,
            }, "outQuint");
        end
    };
};

local indexes = {};

for idx,card in pairs(Cards) do
    indexes[#indexes+1] = idx;
end

function getRandomT1(avoid)
    while true do
        local card = Cards[indexes[math.random(#indexes)]];

        if card.tier==1 and card~=avoid then
            return card;
        end
    end
end

function getRandomT2(avoid)
    while true do
        local card = Cards[indexes[math.random(#indexes)]];

        if card.tier==2 and card~=avoid then
            return card;
        end
    end
end