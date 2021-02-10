function plot_corretto(NODI,ASTE,RT,RTIPER,CC,CCIPER,CD,VELI,VELT,CED,MS)
    d_tratt = 0.02;
    figure;
    % ciclo sulle aste
    n_aste = size(ASTE,1);
    xmedio = sum(NODI(:,2))/size(NODI,1);
    ymedio = sum(NODI(:,3))/size(NODI,1);
    
    for i1 = 1:n_aste
        nodo1 = ASTE(i1,2);
        nodo2 = ASTE(i1,3);
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
        % funzioni asta
        ax = 'xn1 + x*ca';
        ay = 'yn1 + x*sa';
        astax = eval(ax);
        astay = eval(ay);
        % funzioni tratteggio
        if ASTE(i1,4) == 1 % tratteggio a destra
            tx = 'xn1 + d_tratt*sa + x*ca';
            ty = 'yn1 - d_tratt*ca + x*sa';
            trattx = eval(tx);
            tratty = eval(ty);
        elseif ASTE(i1,4) == 2 % tratteggio a sinistra
            tx = 'xn1 - d_tratt*sa + x*ca';
            ty = 'yn1 + d_tratt*ca + x*sa';
            trattx = eval(tx);
            tratty = eval(ty);
        end
        % plot asta
        plot(astax,astay,'k','LineWidth',2);
        axis equal;
        hold on;
        % plot tratteggio
        plot(trattx,tratty,'k--','LineWidth',1);
    end
    %% PLOT CARICHI CONCENTRATI
    for i1 = 1:size(CC,1)
        double_nod = 0;
        altro_nod = [];
        for i2 = 1:size(MS,1)
            if CC(i1,1) == MS(i2,1)
                wow = 1;
                for i3 = 1:size(altro_nod,1)
                    if MS(i2,2) == altro_nod(i3)
                        wow = 0;
                    end
                end
                if wow == 1
                    double_nod = double_nod + 1;
                    altro_nod = [altro_nod;MS(i2,2)];
                end
            elseif CC(i1,1) == MS(i2,2)
                wow = 1;
                for i3 = 1:size(altro_nod,1)
                    if MS(i2,1) == altro_nod(i3)
                        wow = 0;
                    end
                end
                if wow == 1
                    double_nod = double_nod + 1;
                    altro_nod = [altro_nod;MS(i2,1)];
                end
            end
        end
        nodi_cc = [CC(i1,1);altro_nod];
        %% CARICO ORIZZONTALE
        if CC(i1,2) == 1
            % ricerca dell'asta orizzontale a cui associare il carico
            asta_or = 0;
            aste_cc = [];
            for i3 = 1:size(nodi_cc,1)
                for i4 = 1:size(ASTE,1)
                    if (nodi_cc(i3) == ASTE(i4,2)) || (nodi_cc(i3) == ASTE(i4,3))
                        aste_cc = [aste_cc;ASTE(i4,1)];
                    end
                end
            end
            for i5 = 1:size(aste_cc,1)
                nodo1 = ASTE(aste_cc(i5),2);
                nodo2 = ASTE(aste_cc(i5),3);
                xn1 = NODI(nodo1,2);
                xn2 = NODI(nodo2,2);
                yn1 = NODI(nodo1,3);
                yn2 = NODI(nodo2,3);
                if (yn2-yn1) == 0
                    asta_fin = aste_cc(i5);
                    for i5 = 1:size(nodi_cc,1)
                        if nodo1 == nodi_cc(i5)
                            xn = [xn1;xn2];
                            yn = [yn1;yn2];
                        elseif nodo2 == nodi_cc(i5)
                            xn = [xn2;xn1];
                            yn = [yn2;yn1];
                        end
                    end
                end
            end
            if CC(i1,3) > 0
                if xn(2) < xn(1)
                    quiver(xn(1)+0.05,yn(1),0.3,0,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.07,yn(1)+0.07,str);
                elseif xn(2) > xn(1)
                    quiver(xn(1)-0.35,yn(1),0.3,0,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)-0.35,yn(1)+0.07,str);
                end
            else
                if xn(2) < xn(1)
                    quiver(xn(1)+0.35,yn(1),-0.3,0,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.1,yn(1)+0.07,str);
                elseif xn(2) > xn(1)
                    quiver(xn(1)-0.05,yn(1),-0.3,0,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)-0.25,yn(1)+0.07,str);
                end
            end
        end
        %% CARICO VERTICALE
        if CC(i1,2) == 2
            % ricerca dell'asta orizzontale a cui associare il carico
            asta_ver = 0;
            aste_cc = [];
            for i3 = 1:size(nodi_cc,1)
                for i4 = 1:size(ASTE,1)
                    if (nodi_cc(i3) == ASTE(i4,2)) || (nodi_cc(i3) == ASTE(i4,3))
                        aste_cc = [aste_cc;ASTE(i4,1)];
                    end
                end
            end
            for i5 = 1:size(aste_cc,1)
                nodo1 = ASTE(aste_cc(i5),2);
                nodo2 = ASTE(aste_cc(i5),3);
                xn1 = NODI(nodo1,2);
                xn2 = NODI(nodo2,2);
                yn1 = NODI(nodo1,3);
                yn2 = NODI(nodo2,3);
                if (xn2-xn1) == 0
                    asta_fin = aste_cc(i5);
                    for i5 = 1:size(nodi_cc,1)
                        if nodo1 == nodi_cc(i5)
                            xn = [xn1;xn2];
                            yn = [yn1;yn2];
                        elseif nodo2 == nodi_cc(i5)
                            xn = [xn2;xn1];
                            yn = [yn2;yn1];
                        end
                    end
                end
            end
            if CC(i1,3) > 0
                if yn(2) < yn(1)
                    quiver(xn(1),yn(1)+0.05,0,0.3,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.05,yn(1)+0.15,str);
                elseif xn(2) > xn(1)
                    quiver(xn(1),yn(1)-0.35,0,0.3,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.07,yn(1)-0.35,str);
                end
            else
                if yn(2) < yn(1)
                    quiver(xn(1),yn(1)+0.35,0,-0.3,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.05,yn(1)+0.2,str);
                elseif xn(2) > xn(1)
                    quiver(xn(1),yn(1)-0.05,0,-0.3,'k','LineWidth',1,'MaxHeadSize',5);
                    str = strcat(num2str(abs(CC(i1,3))),"qb");
                    text(xn(1)+0.05,yn(1)-0.2,str);
                end
            end
        end
        %% CARICO MOMENTO
        if CC(i1,2) == 3
            % ricerca dell'asta orizzontale a cui associare il carico
            asta_ver = 0;
            aste_cc = [];
            for i3 = 1:size(nodi_cc,1)
                for i4 = 1:size(ASTE,1)
                    if (nodi_cc(i3) == ASTE(i4,2)) || (nodi_cc(i3) == ASTE(i4,3))
                        aste_cc = [aste_cc;ASTE(i4,1)];
                    end
                end
            end
            for i5 = 1:size(aste_cc,1)
                nodo1 = ASTE(aste_cc(i5),2);
                nodo2 = ASTE(aste_cc(i5),3);
                xn1 = NODI(nodo1,2);
                xn2 = NODI(nodo2,2);
                yn1 = NODI(nodo1,3);
                yn2 = NODI(nodo2,3);
                for i5 = 1:size(nodi_cc,1)
                    if nodo1 == nodi_cc(i5)
                        xn = [xn1;xn2];
                        yn = [yn1;yn2];
                    elseif nodo2 == nodi_cc(i5)
                        xn = [xn2;xn1];
                        yn = [yn2;yn1];
                    end
                end
            end
            if CC(i1,3) > 0
                alpha = linspace(-pi/4,3*pi/4,100);
                xm = 'xn(1) + 0.1*cos(alpha)';
                ym = 'yn(1) + 0.1*sin(alpha)';
                xm = eval(xm);
                ym = eval(ym);
                plot(xm,ym,'k','LineWidth',1);
                plot([xn(1) xm(1)],[yn(1) ym(1)],'k','LineWidth',1);
                plot([xm(end) xm(end)+0.07],[ym(end) ym(end)],'k','LineWidth',1);
                plot([xm(end) xm(end)],[ym(end) ym(end)+0.07],'k','LineWidth',1);
                str = strcat(num2str(abs(CC(i1,3))),"qb^2");
                text(xn(1)+(sqrt(2)/2)*0.15,yn(1)-(sqrt(2)/2)*0.15,str);
            else
               alpha = linspace(-pi/4,3*pi/4,100);
                xm = 'xn(1) + 0.1*cos(alpha)';
                ym = 'yn(1) - 0.1*sin(alpha)';
                xm = eval(xm);
                ym = eval(ym);
                plot(xm,ym,'k','LineWidth',1);
                plot([xn(1) xm(1)],[yn(1) ym(1)],'k','LineWidth',1);
                plot([xm(end) xm(end)+0.07],[ym(end) ym(end)],'k','LineWidth',1);
                plot([xm(end) xm(end)],[ym(end) ym(end)-0.07],'k','LineWidth',1);
                str = strcat(num2str(abs(CC(i1,3))),"qb^2");
                text(xn(1)+(sqrt(2)/2)*0.15,yn(1)-(sqrt(2)/2)*0.15,str);
            end
        end
    end
    %% PLOT CARICHI DISTRIBUITI
    for i1 = 1:size(CD,1)
        %% CARICHI DISTRIBUITI
        if (CD(i1,2) ~= 0) || (CD(i1,3) ~= 0)
            nodo1 = ASTE(CD(i1,1),2);
            nodo2 = ASTE(CD(i1,1),3);
            xn1 = NODI(nodo1,2);
            xn2 = NODI(nodo2,2);
            yn1 = NODI(nodo1,3);
            yn2 = NODI(nodo2,3);
            if xn1 == xn2 % carico solo orizzontale
                par = linspace(0,yn2-yn1,10);
                if (xn1+xn2)/2 >= xmedio % plotto a destra
                    cdx1 = 'xn1 + 0.05 + par-par';
                    cdy1 = 'yn1 + par';
                    cdx1 = eval(cdx1);
                    cdy1 = eval(cdy1);
                    cdx2 = 'xn1 + 0.05 + 0.2*(abs(CD(i1,2)) + par*(abs(CD(i1,3))-abs(CD(i1,2))))';
                    cdy2 = 'yn1 + par';
                    cdx2 = eval(cdx2);
                    cdy2 = eval(cdy2);
                    plot(cdx1,cdy1,'k','LineWidth',0.7);
                    plot(cdx2,cdy2,'k','LineWidth',0.7);
                    str = strcat(num2str(abs(CD(i1,2))),",",num2str(abs(CD(i1,3)))," q");
                    text(max(cdx2)+0.05,mean(cdy2),str);
                    if (CD(i1,2) > 0) || (CD(i1,3) > 0)
                        if yn2-yn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),cdx1(i2)-cdx2(i2),0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),cdx2(i2)-cdx1(i2),0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    else
                        if yn2-yn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),cdx2(i2)-cdx1(i2),0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),cdx1(i2)-cdx2(i2),0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    end
                else % plotto a sinistra
                    cdx1 = 'xn1 - 0.05 + par-par';
                    cdy1 = 'yn1 + par';
                    cdx1 = eval(cdx1);
                    cdy1 = eval(cdy1);
                    cdx2 = 'xn1 - 0.05 - 0.2*(abs(CD(i1,2)) - par*(abs(CD(i1,3))-abs(CD(i1,2))))';
                    cdy2 = 'yn1 + par';
                    cdx2 = eval(cdx2);
                    cdy2 = eval(cdy2);
                    plot(cdx1,cdy1,'k','LineWidth',0.7);
                    plot(cdx2,cdy2,'k','LineWidth',0.7);
                    str = strcat(num2str(abs(CD(i1,2))),",",num2str(abs(CD(i1,3)))," q");
                    text(min(cdx2)-0.15,mean(cdy2),str);
                    if (CD(i1,2) > 0) || (CD(i1,3) > 0)
                        if yn2-yn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),cdx2(i2)-cdx1(i2)+0.025,0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),cdx1(i2)-cdx2(i2)+0.025,0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    else
                        if yn2-yn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),cdx1(i2)-cdx2(i2)-0.025,0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),cdx2(i2)-cdx1(i2)-0.025,0,'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    end
                end
            elseif yn2 == yn1 % carico solo verticale
                par = linspace(0,xn2-xn1,10)
                if (yn1+yn2)/2 >= ymedio % plotto sopra
                    cdx1 = 'xn1 + par';
                    cdy1 = 'yn1 + 0.05 + par-par';
                    cdx1 = eval(cdx1);
                    cdy1 = eval(cdy1);
                    cdx2 = 'xn1 + par';
                    cdy2 = 'yn1 + 0.05 + 0.2*(abs(CD(i1,2)) + par*(-(CD(i1,3))+(CD(i1,2))))';
                    cdx2 = eval(cdx2);
                    cdy2 = eval(cdy2);
                    plot(cdx1,cdy1,'k','LineWidth',0.7);
                    plot(cdx2,cdy2,'k','LineWidth',0.7);
                    str = strcat(num2str(abs(CD(i1,2))),",",num2str(abs(CD(i1,3)))," q");
                    text(mean(cdx2),max(cdy2)+0.05,str);
                    if ((CD(i1,2) > 0) || (CD(i1,3) > 0))
                        if xn2-xn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),0,cdy2(i2)-cdy1(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),0,cdy1(i2)-cdy2(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    else
                        if xn2-xn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),0,cdy1(i2)-cdy2(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),0,cdy2(i2)-cdy1(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    end
                else % plotto sotto
                    cdx1 = 'xn1 + par';
                    cdy1 = 'yn1 - 0.05 - par-par';
                    cdx1 = eval(cdx1);
                    cdy1 = eval(cdy1);
                    cdx2 = 'xn1 + par';
                    cdy2 = 'yn1 - 0.05 - 0.2*(abs(CD(i1,2)) - par*(abs(CD(i1,3))-abs(CD(i1,2))))';
                    cdx2 = eval(cdx2);
                    cdy2 = eval(cdy2);
                    plot(cdx1,cdy1,'k','LineWidth',0.7);
                    plot(cdx2,cdy2,'k','LineWidth',0.7);
                    str = strcat(num2str(abs(CD(i1,2))),",",num2str(abs(CD(i1,3)))," q");
                    text(mean(cdx2),max(cdy2)-0.05,str);
                    if ((CD(i1,2) > 0) || (CD(i1,3) > 0))
                        if xn2-xn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),0,cdy1(i2)-cdy2(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),0,cdy2(i2)-cdy1(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    else
                        if xn2-xn1 > 0
                            for i2 = 1:size(par,2)
                                quiver(cdx1(i2),cdy1(i2),0,cdy2(i2)-cdy1(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        else
                            for i2 = 1:size(par,2)
                                quiver(cdx2(i2),cdy2(i2),0,cdy1(i2)-cdy2(i2),'k','LineWidth',0.5,'MaxHeadSize',5);
                            end
                        end
                    end
                end
            end
        end
        %% CARICHI TERMICI
        if (CD(i1,4) ~= 0) || (CD(i1,5) ~= 0)
            nodo1 = ASTE(CD(i1,1),2);
            nodo2 = ASTE(CD(i1,1),3);
            xn1 = NODI(nodo1,2);
            xn2 = NODI(nodo2,2);
            yn1 = NODI(nodo1,3);
            yn2 = NODI(nodo2,3);
        end
    end
end