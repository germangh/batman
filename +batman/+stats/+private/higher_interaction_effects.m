function [subs, signs] = higher_interaction_effects()

subs = nan(4,2);
count = 0;
for i = 1:2
    for j = 1:2
        count = count + 1;
        subs(count,:) = [i j];
    end
end
signs = [1 -1 -1 1];

end