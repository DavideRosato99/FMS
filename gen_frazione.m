function [num,den,rad,cond] = gen_frazione(val,NODI,ASTE)
    prob_rad = [];
    n_aste = size(ASTE,1);
    for i1 = 1:n_aste
        nodo1 = ASTE(i1,2);
        nodo2 = ASTE(i1,3);
        xn1 = NODI(nodo1,2);
        xn2 = NODI(nodo2,2);
        yn1 = NODI(nodo1,3);
        yn2 = NODI(nodo2,3);
        % se l'asta è verticale o orizzontale è inutile il controllo
        if ((xn2-xn1) == 0) || ((yn2-yn1) == 0)
        else
            radice = (xn2-xn1)^2 + (yn2-yn1)^2;
            prob_rad = [prob_rad; radice];
        end
    end
    if val == 0
        num = 0;
        den = 1;
        rad = 0;
        cond = 0;
    else
        % provo con i numeri interi
        for i1 = 1:300
            ip_num = val*i1;
            controllo = abs(ip_num - round(ip_num));
            if controllo < 1e-4
                num = round(ip_num);
                den = i1;
                rad = 0;
                cond = 0;
                return;
            end
        end
        % provo con le radici
        for i1 = 1:length(prob_rad)
            for i2 = 1:100
                ip_num = val*i2/sqrt(prob_rad(i1));
                controllo = abs(ip_num - round(ip_num));
                if controllo < 1e-4
                    num = round(ip_num);
                    den = i2;
                    rad = prob_rad(i1);
                    cond = 1;
                    return;
                end
            end
        end
    end
end