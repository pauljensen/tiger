function [r] = correlation(X)

[nsamples,nvars] = size(X);
r = eye(nvars);

Y = zeros(size(X));
for j = 1 : nvars
    y = X(:,j);
    mean_y = mean(y);
    std_y = std(y);
    Y(:,j) = (y - mean_y)/std_y;
end
    
for i = 1 : nvars
    x = X(:,i);
    mean_x = mean(x);
    std_x = std(x);
    for j = i+1 : nvars
        r(i,j) = sum((x - mean_x)/std_x .* Y(:,j));
    end
end

r = r / (nsamples - 1);
r = r + tril(r');
