% Produce some image
sample = zeros(50,50,3);
for i=10:30
    for j=20:40
        sample(i,j,1:3) = 1;
    end
end

for i=5:15
    for j=30:45
        sample(i,j,1:3) = 0.5;
    end
end

subplot(1,2,1)
image(sample)

subplot(1,2,2)
%image(robertscross(sample))
%image(prewitt(sample))
image(sobel(sample))

