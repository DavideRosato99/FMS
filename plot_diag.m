function plot_diag(coeff,NODI,ASTE,str)
    %% Scala per il plot e distanze relative per il plot dei valori
    d_tratt = 0.05;
    d_val = 0.2;
    scala = 0.2;
    %% programma 
    n_aste = size(ASTE,1);
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
            c0 = round(coeff(i2,i1,1),5);
            c1 = round(coeff(i2,i1,2),5);
            c2 = round(coeff(i2,i1,3),5);
            c3 = round(coeff(i2,i1,4),5);
            % funzioni per il calcolo dei valori agli estremi
            val1 = c0;
            val2 = (c0+c1*L+c2*L^2+c3*L^3);
            % controllo
            alpha = atan2(sa,ca);
            ctr = 1;
            if alpha == 0
                if ASTE(i2,4) == 2
                    ctr = -1;
                end
            elseif ((alpha <= pi/2) && (alpha > 0)) || ((alpha <= -pi/2) && (alpha > -pi))
                if ASTE(i2,4) == 2
                    ctr = -1;
                end
            elseif (alpha == pi)
                if ASTE(i2,4) == 2
                    ctr = -1;
                end
            elseif ((alpha > pi/2) && (alpha < pi)) || ((alpha < 0) && (alpha > -pi/2))
                if ASTE(i2,4) == 2
                    ctr = -1;
                end
            end
            % coefficienti
            c0 = ctr*c0;
            c1 = ctr*c1;
            c2 = ctr*c2;
            c3 = ctr*c3;
            % FUNZIONI PLOTTAGGIO PARAMTERIZZATE CON X
            % funzioni valore
            Fx = 'xn1 + scala*(c0+c1*x+c2*x.^2+c3*x.^3)*(sa) + x*ca';
            Fy = 'yn1 - scala*(c0+c1*x+c2*x.^2+c3*x.^3)*(ca) + x*sa';
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
            elseif ASTE(i2,4) == 2 % tratteggio a sinistra
                tx = 'xn1 - d_tratt*sa + x*ca';
                ty = 'yn1 + d_tratt*ca + x*sa';
                trattx = eval(tx);
                tratty = eval(ty);
            end
            % plot asta
            plot(astax,astay,'k','LineWidth',2);
            axis equal;
            hold on;
            % plot marker separatori aste
            plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
            plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
            % plot tratteggio
            plot(trattx,tratty,'--','MarkerFaceColor','r','MarkerEdgeColor','r');
            % plot valore
            plot(valx,valy,'b','LineWidth',1);
            % posizione dei valori agli estremi
            alpha = atan2(sa,ca);
            alpha1 = -pi/6;
            x_text_val1 = xn1 + d_val*cos(alpha-alpha1);
            y_text_val1 = yn1 + d_val*sin(alpha-alpha1);
            x_text_val2 = xn2 + d_val*cos(alpha+pi+alpha1);
            y_text_val2 = yn2 + d_val*sin(alpha+pi+alpha1);
            text(x_text_val1,y_text_val1,num2str(val1));
            text(x_text_val2,y_text_val2,num2str(val2));
        end
    end
end