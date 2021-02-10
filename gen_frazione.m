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
            break; % uscita dal ciclo
        else
            radice = (xn2-xn1)^2 + (yn2-yn1)^2;
            prob_rad = [prob_rad; radice];
        end
    end
    s = false;
    for i1 = 1:1:5000
        controllo = val*i1;
        if (abs(controllo-round(controllo)) < 1e-4) && (s == false)
            den = i1;
            num = round(controllo,1);
            rad = 0;
            cond = 0;
            s = true;
            break; % uscita dal ciclo
        end
    end
    % se non esiste frazione "intera" allora prova con le radici sopra
    % trovate
    if s == false
        for i1 = 1:1:5000
            for i2 = 1:length(prob_rad)
                controllo = (val*i1)/sqrt(prob_rad(i2));
                if (abs(controllo-round(controllo)) < 1e-4) && (s == false)
                    den = i1;
                    num = round(controllo,1);
                    rad = prob_rad(i2);
                    cond = 1;
                    s = true;
                    break % uscita dal ciclo
                end
                if s == true
                    break
                end
            end
            if s == true
                break
            end
        end
    end
end