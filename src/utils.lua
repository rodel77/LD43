function color(r, g, b, a)
    if not b then
        -- a = bit.rshift(bit.band(r, 0xFF000000), 24)/255;
        a = g or 1;
        g = bit.rshift(bit.band(r, 0xFF00), 8)/255;
        b = bit.band(r, 0xFF)/255;
        r = bit.rshift(bit.band(r, 0xFF0000), 16)/255;
    end

    love.graphics.setColor(r, g, b, a);
end

function black(alpha)
    love.graphics.setColor(0.07, 0.07, 0.07, alpha or 1);
end

function white(alpha)
    love.graphics.setColor(1, 1, 1, alpha or 1);
end

function lerp(a, b, t)
    return (1 - t) * a + t * b;
end

function map(n, start1, stop1, start2, stop2)
    return (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
end

function collide(ox, oy, w, h, x, y)
    return x >= ox and x <= ox+w and y >= oy and y <= oy+h;
end

function chance50()
    return math.random(100)>50;
end

function chance20()
    return math.random(100)<20;
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end