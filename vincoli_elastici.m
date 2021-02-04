function [KstfG,F_extG] = vincoli_elastici(KstfG,F_extG,VELT,VELI,igl)
    n_velt = size(VELT,1);
    for i1 = 1:n_velt
        nodo = VELT(i1,1);
        dir = VELT(i1,2);
        valore = VELT(i1,3);
        jgl = igl(nodo,dir);
        if jgl > 0
            KstfG(jgl,jgl) = KstfG(jgl,jgl) + valore;
        end
    end
    n_veli = size(VELI,1);
    for i1 = 1:n_veli
        nodo1 = VELI(i1,1);
        nodo2 = VELI(i1,2);
        dir = VELI(i1,3);
        valore = VELI(i1,4);
        jgl1 = igl(nodo1,dir);
        jgl2 = igl(nodo2,dir);
        if (jgl1 > 0) && (jgl2 > 0)
            KstfG(jgl1,jgl1) = KstfG(jgl1,jgl1) + valore;
            KstfG(jgl2,jgl2) = KstfG(jgl2,jgl2) + valore;
            KstfG(jgl1,jgl2) = KstfG(jgl1,jgl2) - valore;
            KstfG(jgl2,jgl1) = KstfG(jgl2,jgl1) - valore;
        end
    end
end