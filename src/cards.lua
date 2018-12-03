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
            return true;
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
            return true;
        end
    };

    nocere = Card:create{
        name = "Nocere",
        description = "50%: Damage x2 in the next 5 attacks\n50%: Damage x1.5 in the next 5 attacks",
        ref = "perdere",
        tier = 1,
        image = 9,
        use = function()
            GameState.damage_bonus_count = 5;
            GameState.damage_bonus = chance50() and 2 or 1.5;
            return true;
        end
    };
    perdere = Card:create{
        name = "Perdere",
        description = "50%: Damage x2 in the next 5 attacks\n50%: Kills the next enemy you attack",
        ref = "nocere",
        tier = 2,
        image = 10,
        use = function()
            if chance50() then
                GameState.damage_bonus_count = 5;
                GameState.damage_bonus = 2;
            else
                GameState.damage_bonus_count = 1;
                GameState.damage_bonus = 100;
            end
            return true;
        end
    };

    occidere = Card:create{
        name = "Occidere",
        description = "50%: Duplicates a card\n50%: Burn a card",
        ref = "duplis",
        tier = 1,
        image = 7,
        use = function()
            if #GameState.cards>0 then
                GameState.select_card = true;
                GameState.on_select_card = function(i)
                    if chance50() then
                        table.insert(GameState.cards, GameState.cards[i]);
                        sounds.upgrade:play();
                    else
                        table.remove(GameState.cards, i);
                        sounds.dead:play();
                    end
                end
                return true;
            else
                sounds.no:play();
                return false;
            end
        end
    };
    duplis = Card:create{
        name = "Duplis",
        description = "70% Duplicates a card\n30% Duplicates and upgrade a card (tier 2 covert to 1)",
        ref = "occidere",
        tier = 2,
        image = 8,
        use = function()
            if #GameState.cards>0 then
                GameState.select_card = true;
                GameState.on_select_card = function(i)
                    if chance(70) then
                        table.insert(GameState.cards, GameState.cards[i]);
                        sounds.upgrade:play();
                    else
                        table.insert(GameState.cards, GameState.cards[GameState.cards[i].ref]);
                        sounds.upgrade_finish:play();
                    end
                end
                return true;
            else
                sounds.no:play();
                return false;
            end
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
            return true;
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
        description = "70%: Lose all your cards\n30%: Get 5 cards",
        ref = "sacrificium2",
        tier = 1,
        image = 4,
        use = function()
            if chance(70) then
                sounds.no:play();
                GameState.cards = {};
            else
                sounds.buy:play();
                for i=1,4 do
                    GameState.cards[#GameState.cards+1] = getRandomT1();
                end
                GameState.cards[#GameState.cards+1] = getRandomT2();
            end
            return true;
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
            return true;
        end
    };
};

local indexes = {};

for idx,card in pairs(Cards) do
    indexes[#indexes+1] = idx;
end

local lastTier1 = Cards.occidere;
local lastTier2 = nil;

function getRandomT1(avoid)
    while true do
        local card = Cards[indexes[math.random(#indexes)]];

        if card.tier==1 and card~=avoid and card~=lastTier1 then
            lastTier1 = card;
            return card;
        end
    end
end

function getRandomT2(avoid)
    while true do
        local card = Cards[indexes[math.random(#indexes)]];

        if card.tier==2 and card~=avoid and card~=lastTier2 then
            lastTier2 = card;
            return card;
        end
    end
end