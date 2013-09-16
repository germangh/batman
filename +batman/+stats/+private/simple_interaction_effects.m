function [subs, signs] = simple_interaction_effects()

subs = nan(4,2);
count = 0;
for i = 1:2
    for j = 2:-1:1
        count = count + 1;
        subs(count,:) = [i j];
    end
end
signs = [-1 1 -1 1];

end
