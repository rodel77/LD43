function color(r, g, b, a)
    if not g then
        a = bit.rshift(bit.band(r, 0xFF000000), 24)/255;
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