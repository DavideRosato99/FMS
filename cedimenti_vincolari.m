function [KstfG,F_extG] = cedimenti_vincolari(KstfG,F_extG,CED,igl,n_gdl)
    n_cedv = size(CED);
    for i1 = 1:n_cedv
        nodo = CED(i1,1);
        direzione = CED(i1,2);
        cedimento = CED(i3,3);
        jgl = igl(nodo,direzione);
        if jgl > 0
            for i2 = 1:n_gdl
                KstfG(jgl,i2) = 0;
                F_extG(i2) = F_extG(i2) - KstfG(i2,jgl)*cedimento;
                KstfG(i2,jgl) = 0;
            end
            KstfG(jgl,jgl) = 1;
            F_extG(jgl) = cedimento;
        end
    end
end