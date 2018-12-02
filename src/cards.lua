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
        description = "50%: Max heal\n50%: Heal to 1",
        image = 1,
    };
};