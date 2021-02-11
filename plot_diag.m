function plot_diag(coeff,NODI,ASTE,str)
    %% Scala per il plot e distanze relative per il plot dei valori
    d_tratt = 0.02;
    d_val = 0.2;
    scala = 0.2;
    d_linee = 0.02;
    %% programma 
    n_aste = size(ASTE,1);
    % settaggio della scala 
    for i1 = 1:3
        val_max_vec = [];
        for i2 = 1:n_aste
            nodo1 = ASTE(i2,2);
            nodo2 = ASTE(i2,3);
            xn1 = NODI(nodo1,2);
            xn2 = NODI(nodo2,2);
            yn1 = NODI(nodo1,3);
            yn2 = NODI(nodo2,3);
            dx = xn2 - xn1;
            dy = yn2 - yn1;
            L = sqrt(dx^2 + dy^2);
            ca = dx/L;
            sa = dy/L;
            % inizializzazione incognita di parametrizzazione x
            x = 0:L/100:L;
            % coefficienti
            c0 = round(coeff(i2,i1,1),5);
            c1 = round(coeff(i2,i1,2),5);
            c2 = round(coeff(i2,i1,3),5);
            c3 = round(coeff(i2,i1,4),5);
            % funzioni per il calcolo dei valori agli estremi
            val1 = abs(c0);
            val2 = abs((c0+c1*L+c2*L^2+c3*L^3));
            val_max_vec = [val_max_vec,max(val1,val2)];
        end
        max_val = max(val_max_vec);
        if max_val ~= 0
            scala_ip = scala/max_val;
        else
            scala_ip = 1;
        end
        scala_vec(i1,1) = scala_ip;
    end
    NOME = ['N';'T';'M'];
    % ciclo su N,T,M
    for i1 = 1:3
        figure('Name',strcat(str," - ",NOME(i1)));
        % ciclo sulle aste
        for i2 = 1:n_aste
            nodo1 = ASTE(i2,2);
            nodo2 = ASTE(i2,3);
            xn1 = NODI(nodo1,2);
            xn2 = NODI(nodo2,2);
            yn1 = NODI(nodo1,3);
            yn2 = NODI(nodo2,3);
            dx = xn2 - xn1;
            dy = yn2 - yn1;
            L = sqrt(dx^2 + dy^2);
            ca = dx/L;
            sa = dy/L;
            % inizializzazione incognita di parametrizzazione x
            x = 0:L/100:L;
            % coefficienti
            c0 = coeff(i2,i1,1);
            c1 = coeff(i2,i1,2);
            c2 = coeff(i2,i1,3);
            c3 = coeff(i2,i1,4);
            % funzioni per il calcolo dei valori agli estremi
            val1 = c0;
            val2 = (c0+c1*L+c2*L^2+c3*L^3);
            % controllo
            alpha = atan2(sa,ca);
            ctr = 1;
            if ASTE(i2,4) == 2
                ctr = -1;
                val1 = ctr*c0;
                val2 = ctr*(c0+c1*L+c2*L^2+c3*L^3);
            end
            % coefficienti
            c0 = c0;
            c1 = c1;
            c2 = c2;
            c3 = c3;
            % FUNZIONI PLOTTAGGIO PARAMTERIZZATE CON X
            % funzioni valore
            Fx = 'xn1 + scala_vec(i1,1)*(c0+c1*x+c2*x.^2+c3*x.^3)*(sa) + x*ca';
            Fy = 'yn1 - scala_vec(i1,1)*(c0+c1*x+c2*x.^2+c3*x.^3)*(ca) + x*sa';
            valx = eval(Fx);
            valy = eval(Fy);
            % funzioni asta
            ax = 'xn1 + x*ca';
            ay = 'yn1 + x*sa';
            astax = eval(ax);
            astay = eval(ay);
            % funzioni tratteggio
            if ASTE(i2,4) == 1 % tratteggio a destra
                tx = 'xn1 + d_tratt*sa + x*ca';
                ty = 'yn1 - d_tratt*ca + x*sa';
                trattx = eval(tx);
                tratty = eval(ty);
                num_poss = round(L/d_linee);
                for i3 = 1:1:num_poss
                    p_inx = 'xn1 + i3*d_linee*ca';
                    p_iny = 'yn1 + i3*d_linee*sa';
                    p_finx = 'xn1 + scala_vec(i1,1)*(c0+c1*(i3*d_linee)+c2*(i3*d_linee).^2+c3*(i3*d_linee).^3)*(sa) + i3*d_linee*ca';
                    p_finy = 'yn1 - scala_vec(i1,1)*(c0+c1*(i3*d_linee)+c2*(i3*d_linee).^2+c3*(i3*d_linee).^3)*(ca) + i3*d_linee*sa';
                    punto_in_x = eval(p_inx);
                    punto_in_y = eval(p_iny);
                    punto_fin_x = eval(p_finx);
                    punto_fin_y = eval(p_finy);
                    plot([punto_in_x,punto_fin_x],[punto_in_y,punto_fin_y],'b','LineWidth',0.2);
                    hold on;
                end
            elseif ASTE(i2,4) == 2 % tratteggio a sinistra
                tx = 'xn1 - d_tratt*sa + x*ca';
                ty = 'yn1 + d_tratt*ca + x*sa';
                trattx = eval(tx);
                tratty = eval(ty);
                num_poss = round(L/d_linee);
                for i3 = 1:1:num_poss
                    p_inx = 'xn1 + i3*d_linee*ca';
                    p_iny = 'yn1 + i3*d_linee*sa';
                    p_finx = 'xn1 + scala_vec(i1,1)*(c0+c1*(i3*d_linee)+c2*(i3*d_linee).^2+c3*(i3*d_linee).^3)*(sa) + i3*d_linee*ca';
                    p_finy = 'yn1 - scala_vec(i1,1)*(c0+c1*(i3*d_linee)+c2*(i3*d_linee).^2+c3*(i3*d_linee).^3)*(ca) + i3*d_linee*sa';
                    punto_in_x = eval(p_inx);
                    punto_in_y = eval(p_iny);
                    punto_fin_x = eval(p_finx);
                    punto_fin_y = eval(p_finy);
                    plot([punto_in_x,punto_fin_x],[punto_in_y,punto_fin_y],'b','LineWidth',0.2);
                    hold on;
                end
            end
            % plot asta
            plot(astax,astay,'k','LineWidth',2.5);
            axis equal;
            hold on;
            % plot marker separatori aste
            plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
            plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
            % plot tratteggio
            plot(trattx,tratty,'k--','LineWidth',1);
            % plot valore
            plot(valx,valy,'b','LineWidth',1);
            % posizione dei valori agli estremi
            alpha = atan2(sa,ca);
            alpha1 = -pi/6;
            x_text_val1 = xn1 + d_val*cos(alpha-alpha1);
            y_text_val1 = yn1 + d_val*sin(alpha-alpha1);
            x_text_val2 = xn2 + d_val*cos(alpha+pi+alpha1);
            y_text_val2 = yn2 + d_val*sin(alpha+pi+alpha1);
            % calcolo dell'eventuale frazione per poterla mettere nel plot
            [num1,den1,rad1,cond1] = gen_frazione(val1,NODI,ASTE);
            if cond1 == 1 % se c'è la radice
                if den1 == 1
                    textval1 = strcat("(",num2str(num1),"√",num2str(rad1),")");
                else
                    textval1 = strcat("(",num2str(num1),"√",num2str(rad1),")/",num2str(den1));
                end
            else % se non c'è la radice
                if den1 == 1
                    textval1 = num2str(num1);
                else
                    textval1 = strcat(num2str(num1),"/",num2str(den1));
                end
            end
            [num2,den2,rad2,cond2] = gen_frazione(val2,NODI,ASTE);
            if cond2 == 1 % se c'è la radice
                if den2 == 1
                    textval2 = strcat("(",num2str(num2),"√",num2str(rad2),")");
                else
                    textval2 = strcat("(",num2str(num2),"√",num2str(rad2),")/",num2str(den2));
                end
            else % se non c'è la radice
                if den2 == 1
                    textval2 = num2str(num2);
                else
                    textval2 = strcat(num2str(num2),"/",num2str(den2));
                end
            end
            text(x_text_val1,y_text_val1,textval1);
            text(x_text_val2,y_text_val2,textval2);
            plot([xn1,valx(1)],[yn1,valy(1)],'b','LineWidth',0.2);
            plot([xn2,valx(end)],[yn2,valy(end)],'b','LineWidth',0.2);
        end
    end
end