% Returns skeleton of image
% Method described by Zhang and Suen in
% http://www-prima.inrialpes.fr/perso/Tran/Draft/gateway.cfm.pdf
function boney_image = skel(o_i)
% These 2 are globals used by P(x)
i_indices = [0 -1 -1 0 1 1 1 0 -1];
j_indices = [0 0 1 1 1 0 -1 -1 -1];

% convert image to B&W
o_i = im2bw(o_i);
[R, C] = size(o_i);
% pad image to access "out of bound issues"
o_i = padarray(o_i,[1 1],0);

Continue = 0;
M = zeros(R+2,C+2);
while 1
    for i = 2:R+1
        for j = 2:C+1
            if o_i(i,j) == 0
                continue
            end
            
            B = P(2) + P(3) + P(4) + P(5) + P(6) + P(7) + P(8) + P(9);
            % Conditions:
            %   A(P1) = 1
            %   2 <= B(P1) <= 6
            %   P2*P4*P6 = 0
            %   P4*P6*P8 = 0
            if ComputeA() == 1 && B >= 2 && B <= 6 && P(2)*P(4)*P(6) == 0 && P(4)*P(6)*P(8) == 0
                Continue = Continue + 1;
                M(i,j) = 1;
            end
        end
    end
    
    o_i = o_i - M;
    M = zeros(R+2,C+2);
    if Continue == 0
        break;
    end
    Continue = 0;
    
    % do second subiteration
    for i = 2:R+1
        for j = 2:C+1
            if o_i(i,j) == 0
                continue
            end
            % calculate B(P1) for new image
            B = P(2) + P(3) + P(4) + P(5) + P(6) + P(7) + P(8) + P(9);
            
            % Conditions:
            %   A(P1) = 1
            %   2 <= B(P1) <= 6
            %   P2*P4*P8 = 0
            %   P2*P6*P8 = 0
            if ComputeA() == 1 && B >= 2 && B <= 6 && P(2)*P(4)*P(8) == 0 && P(2)*P(6)*P(8) == 0
                Continue = Continue + 1;
                M(i,j) = 1;
            end
        end
    end
    
    o_i = o_i - M;
    M = zeros(R+2,C+2);
    
    if Continue == 0
        break;
    end
end

% Remove padding when returning image
boney_image = o_i(2:end-1,2:end-1);


    function val = P(idx)
        val = o_i(i+i_indices(idx), j+j_indices(idx));
    end

    function b = ComputeA()
        b = 0;
        if P(2) == 0 && P(3) == 1
            b = b+1;
        end
        if P(3) == 0 && P(4) == 1
            b = b+1;
        end
        if P(4) == 0 && P(5) == 1
            b = b+1;
        end
        if P(5) == 0 && P(6) == 1
            b = b+1;
        end
        if P(6) == 0 && P(7) == 1
            b = b+1;
        end
        if P(7) == 0 && P(8) == 1
            b = b+1;
        end
        if P(8) == 0 && P(9) == 1
            b = b+1;
        end
        if P(9) == 0 && P(2) == 1
            b = b+1;
        end
    end

end


