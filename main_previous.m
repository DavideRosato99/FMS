clc;
close all;
clear all;
format rat

%..........................................................................
%% INSERISCI I DATI QUI
% NODI % devono essere in ordine
n_nodi = 4;
NODI = ...
    [1,0,1
    2,1,1
    3,1,1
    4,1,0];
% ASTE % devono essere in ordine
n_aste = 2; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,1
    2,3,4,1];
% REAZIONI A TERRA
n_rt = 4;
RT = ...
    [1,1
    1,2
    4,1
    4,2];
% REAZIONI MASTER SLAVE
n_ms = 3;
MS = ...
    [2,3,1
    2,3,2];
% CARICHI SUI NODI
n_cc = 0;
CC = ...
    [];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 2;
CCIPER = ...
    [2,3,-1
    3,3,1];
% CARICHI DISTRIBUITI
n_cd = 1; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,0,0,1,1
   2,0,0,0,0];
%..........................................................................

%% RISOLUZIONE
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD);
[coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD);
coeff0(1,2,:)
coeffIPER(1,2,:)





error('ciao');
syms b E q I R
assume(b,'integer');
assume(b>0);
% creazione matrice nodale igl
igl = zeros(n_nodi,3);
% modifica a causa delle reazioni a terra
for i1 = 1:n_nodi
    for i2 = 1:size(RT,1)
        if RT(i2,1) == i1
            igl(i1,RT(i2,2)) = -1;
        end
    end
end

%% modifica a causa delle relazioni master-slave
for i = 1:size(MS,1)
    igl(MS(i,2),MS(i,3)) = MS(i,1);
end

%% conteggio gradi di libertà
n_gdl = 0;
for i1 = 1:n_nodi
    for i2 = 1:3
        if igl(i1,i2) == 0
            n_gdl = n_gdl +1;
            igl(i1,i2) = n_gdl;
        elseif igl(i1,i2) > 0
            nodM = igl(i1,i2);
            igl(i1,i2) = igl(nodM,i2);
        end
    end
end
igl

%% creazione matrice dei carichi esterni sui nodi
car_con = zeros(n_gdl,1);
for i1 = 1:size(CC,1)
    nodo = CC(i1,1);
    direzione = CC(i1,2);
    forza = CC(i1,3);
    jgl = igl(nodo,direzione);
    if jgl > 0
        car_con(jgl) = car_con(jgl) + forza;
    end
end
car_con
%% creazione matrice dei carichi distribuiti
car_dis = zeros(n_aste,2);
for i1 = 1:size(CD,1)
    elemento = CD(i1,1);
    car_dis(elemento,1:2) = car_dis(elemento,1:2) + ...
        CD(i1,2:3);
end
car_dis

%% inizializzazione matrice di rigidezza totale
KstfG = sym(zeros(n_gdl,n_gdl));

%% inizializzazione vettore  carichi globali
F_extG = sym(zeros(n_gdl,1));

%% copia carichi concentrati ai nodi
F_extG(1:n_gdl)=car_con(1:n_gdl);
F_extG

%% matrice forze globale
for elem = 1:n_aste
    [Ke,Fe] = matrice_finale(elem,NODI,ASTE,CD);
    nodo1 = ASTE(elem,2);
    nodo2 = ASTE(elem,3);
    gdlE(1:6) = [igl(nodo1,1:3) igl(nodo2,1:3)]
    for i1 = 1:6
        if gdlE(i1) > 0
            F_extG(gdlE(i1))=F_extG(gdlE(i1))+Fe(i1);
            for i2 = 1:6
                if gdlE(i2) > 0
                    KstfG(gdlE(i1),gdlE(i2))=KstfG(gdlE(i1),gdlE(i2))+Ke(i1,i2);
                end
            end
        end
    end
end
KstfG
F_extG

disp_vec = sym(zeros(n_gdl,1));
disp_vec = KstfG\F_extG;
disp_vec

%% Ricostruzione degli spostamenti per i diagrammi
[azioni_interne] = final_eval(n_aste,CD,ASTE,NODI,igl,disp_vec);
azioni_interne(1,3,:)

% Equazioni simboliche tratto per tratto
%% TAGLIO
scala_T = 0.5;
figure;
for elem = 1:n_aste
    nodo1 = ASTE(elem,2);
    nodo2 = ASTE(elem,3);
    xn1 = NODI(nodo1,2);
    xn2 = NODI(nodo2,2);
    yn1 = NODI(nodo1,3);
    yn2 = NODI(nodo2,3);
    dx = (xn2-xn1);
    dy = (yn2-yn1);
    l = sqrt(dx^2 + dy^2);
    ca = dx/l;
    sa = dy/l;
    c0 = simplify(azioni_interne(elem,2,1))
    c1 = simplify(azioni_interne(elem,2,2))
    c2 = simplify(azioni_interne(elem,2,3))
    c3 = simplify(azioni_interne(elem,2,4))
    Tx ='x*ca + scala_T*(c0+c1*x+c2*x.^2+c3*x.^3)*sa+xn1';
    Ty ='x*sa - scala_T*(c0+c1*x+c2*x.^2+c3*x.^3)*ca+yn1';
    x = 0:l/100:l;
    puntatore = [(xn2-xn1);(yn2-yn1)];
    if puntatore(1) > 0
        ctr = 1;
    elseif puntatore(1) < 0
        ctr = -1;
    elseif puntatore(1) == 0
        ctr = 0;
    end
    format rat
    if ctr ~= 0 % se asta non è verticale
        % plot asta
        astax = 'x*ca + xn1';
        astay = 'x*sa + yn1';
        plot(eval(astax),eval(astay),'k','LineWidth',2);
        axis equal;
        hold on;
        plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
        plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
        % plot del tratteggio
        if ((ASTE(elem,4) == 1) && (ctr ==1)) || ((ASTE(elem,4) == 2) && (ctr == -1))
            trattx = 'x*ca + 0.1*ctr*sa + xn1';
            tratty = 'x*sa - 0.1*ctr*ca + yn1';
            plot(eval(trattx),eval(tratty),'--');
        elseif ((ASTE(elem,4) == 2) && (ctr ==1)) || ((ASTE(elem,4) == 1) && (ctr == -1)) %tratteggio sinistra
            trattx = 'x*ca - 0.1*ctr*sa + xn1';
            tratty = 'x*sa + 0.1*ctr*ca + yn1';
            plot(eval(trattx),eval(tratty),'--');
        end
        % vettori di punti per creazione plot e testo equazione
        vecx = [eval(Tx)];
        vecy = [eval(Ty)];
        if (ctr == 1) && (ASTE(elem,4)==1)
            plot(vecx,vecy,'b','LineWidth',1.5);
            val = double(c0)
            str = num2str(val);
            text((xn1+0.05*ca+0.05*sa),(yn1+0.05*sa-0.05*ca),str);
            val = double(c0 + c1*l + c2*l^2 + c3*l^3);
            str = num2str(val)
            text((xn2-0.05*ca+0.05*sa),(yn2-0.05*sa-0.05*ca),str);
            str = ['(' num2str(double(c0)) ')qb + (' num2str(double(c1)) ')qx'];
            text(xn1-0.2+(xn2-xn1)/2+0.05*ca,yn1+(yn2-yn1)/2-0.05*(1-sa),str);
            quiver(xn1+(-0.05*sa),yn1+0.05*ca,0.2*ca,0.2*sa,'r','LineWidth',2)
            text(xn1+(-0.05*sa)+ 0.2*ca,yn1+0.05*ca + 0.2*sa,'x')
            hold on;
        elseif (ctr == 1) && (ASTE(elem,4)==2)
            plot(vecx-2*(vecx(1)-xn1),vecy+2*(yn1-vecy(1)),'b','LineWidth',1.5);
            val = sign(double(c0+c1*xn1+c2*xn1^2+c3*xn1^3))*double(sqrt((vecx(1)/scala_M-xn1)^2+(vecy(1)/scala_M-yn1)^2));
            str = num2str(val);
            text((xn1+0.05),(yn1+0.05),str);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3)*double(sqrt((vecx(end)-xn2)^2+(vecy(end)-yn2)^2));
            str = num2str(val);
            text((xn2-0.1),(yn2+0.05),str);
            hold on;
        elseif (ctr == -1) && (ASTE(elem,4)==2)
            plot(vecx-2*(vecx(end)-xn2),vecy+2*(yn2-vecy(end)),'b','LineWidth',1.5);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
            str = num2str(val);
            text((xn1-0.1),(yn1-0.05),str);
            val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
            str = num2str(val);
            text((xn2+0.05),(yn2-0.05),str);
            hold on;
        elseif (ctr == -1) && (ASTE(elem,4)==1)
            plot(vecx,vecy,'b','LineWidth',1.5);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
            str = num2str(val);
            text((xn1-0.1),(yn1+0.05),str);
            val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
            str = num2str(val);
            text((xn2+0.05),(yn2+0.05),str);
            hold on;
        end
    else % se asta verticale
        % plot asta
        astax = 'x*ca + xn1';
        astay = 'x*sa + yn1';
        plot(eval(astax),eval(astay),'k','LineWidth',2); 
        axis equal;
        hold on;
        grid on;
        plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
        plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
        % plot del tratteggio
        if ((ASTE(elem,4) == 1) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 1) && ((yn2-yn1)<0)) % tratteggio destra
            trattx = 'x*ca + 0.1*sa + xn1';
            tratty = 'x*sa - 0.1*ca + yn1';
            plot(eval(trattx),eval(tratty),'--');
        elseif ((ASTE(elem,4) == 2) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 2) && ((yn2-yn1)<0)) %tratteggio sinistra
            trattx = 'x*ca - 0.1*sa + xn1';
            tratty = 'x*sa + 0.1*ca + yn1';
            plot(eval(trattx),eval(tratty),'--');
        end
            % vettori di punti per creazione plot
        vecx = [eval(Tx)];
        vecy = [eval(Ty)];
        if (ASTE(elem,4)==1) && ((yn2-yn1)>0)
            plot(vecx,vecy,'b','LineWidth',1.5);
            val = double(c0)
            str = num2str(val);
            text((xn1+0.05),(yn1+0.05),str);
            val = double(c0 + c1*l + c2*l^2 + c3*l^3);
            str = num2str(val)
            text((xn2+0.05),(yn2-0.05),str);
            str = ['(' num2str(double(c0)) ')qb + (' num2str(double(c1)) ')qx'];
            text((xn2-xn1)/2+0.02,(yn2-yn1)/2,str);
            quiver(xn1+(-0.05*sa),yn1+0.05*ca,0.2*ca,0.1*sa,'r','LineWidth',2)
            text(xn1+(-0.05*sa)+ 0.2*ca,yn1+0.05*ca + 0.1*sa,'x')
            hold on;
        elseif (ASTE(elem,4)==2) && ((yn2-yn1)>0)
            plot(-vecx,vecy,'b','LineWidth',1.5);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
            str = num2str(val);
            text((xn1-0.1),(yn1+0.1),str);
            val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
            str = num2str(val);
            text((xn2-0.1),(yn2-0.1),str);
            hold on;
        elseif (ASTE(elem,4)==1) && ((yn2-yn1)<0)
            plot(vecx,vecy,'b','LineWidth',1.5);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
            str = num2str(val);
            text((xn1-0.1),(yn1-0.1),str);
            val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
            str = num2str(val);
            text((xn2-0.1),(yn2+0.1),str);
            hold on;
        elseif (ASTE(elem,4)==2) && ((yn2-yn1)<0)
            plot(-vecx,vecy,'b','LineWidth',1.5);
            val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
            str = num2str(val);
            text((xn1+0.05),(yn1-0.1),str);
            val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
            str = num2str(val);
            text((xn2+0.05),(yn2+0.1),str);
            hold on;
        end
    end
end

%% TRAZIONE
% scala_N = 0.5;
% figure;
% for elem = 1:n_aste
%     nodo1 = ASTE(elem,2);
%     nodo2 = ASTE(elem,3);
%     xn1 = NODI(nodo1,2);
%     xn2 = NODI(nodo2,2);
%     yn1 = NODI(nodo1,3);
%     yn2 = NODI(nodo2,3);
%     dx = (xn2-xn1);
%     dy = (yn2-yn1);
%     l = sqrt(dx^2 + dy^2);
%     ca = dx/l;
%     sa = dy/l;
%     c0 = simplify(azioni_interne(elem,1,1));
%     c1 = simplify(azioni_interne(elem,1,2));
%     c2 = simplify(azioni_interne(elem,1,3));
%     c3 = simplify(azioni_interne(elem,1,4));
%     Nx ='x*ca + scala_N*(c0+c1*x+c2*x.^2+c3*x.^3)*sa+xn1';
%     Ny ='x*sa - scala_N*(c0+c1*x+c2*x.^2+c3*x.^3)*ca+yn1';
%     x = 0:l/100:l;
%     puntatore = [(xn2-xn1);(yn2-yn1)];
%     if puntatore(1) > 0
%         ctr = 1;
%     elseif puntatore(1) < 0
%         ctr = -1;
%     elseif puntatore(1) == 0
%         ctr = 0;
%     end
%     format rat
%     if ctr ~= 0 % se asta non è verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2);
%         axis equal;
%         hold on;
%         grid on;
%         plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         % plot del tratteggio
%         if ((ASTE(elem,4) == 1) && (ctr ==1)) || ((ASTE(elem,4) == 2) && (ctr == -1))
%             trattx = 'x*ca + 0.1*ctr*sa + xn1';
%             tratty = 'x*sa - 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ((ASTE(elem,4) == 2) && (ctr ==1)) || ((ASTE(elem,4) == 1) && (ctr == -1)) %tratteggio sinistra
%             trattx = 'x*ca - 0.1*ctr*sa + xn1';
%             tratty = 'x*sa + 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%         % vettori di punti per creazione plot e testo equazione
%         vecx = [eval(Nx)];
%         vecy = [eval(Ny)];
%         if (ctr == 1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1-0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2-0.05),str);
%             hold on;
%         elseif (ctr == 1) && (ASTE(elem,4)==2)
%             plot(vecx-2*(vecx(1)-xn1),vecy+2*(yn1-vecy(1)),'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1+0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2+0.05),str);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==2)
%             plot(vecx-2*(vecx(end)-xn2),vecy+2*(yn2-vecy(end)),'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1-0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2-0.05),str);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1+0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2+0.05),str);
%             hold on;
%         end
%     else % se asta verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         grid on;
%         plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         % plot del tratteggio
%         if ((ASTE(elem,4) == 1) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 1) && ((yn2-yn1)<0)) % tratteggio destra
%             trattx = 'x*ca + 0.1*sa + xn1';
%             tratty = 'x*sa - 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ((ASTE(elem,4) == 2) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 2) && ((yn2-yn1)<0)) %tratteggio sinistra
%             trattx = 'x*ca - 0.1*sa + xn1';
%             tratty = 'x*sa + 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%             % vettori di punti per creazione plot
%         vecx = [eval(Nx)];
%         vecy = [eval(Ny)];
%         if (ASTE(elem,4)==1) && ((yn2-yn1)>0)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1+0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2-0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==2) && ((yn2-yn1)>0)
%             plot(-vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1+0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2-0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==1) && ((yn2-yn1)<0)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1-0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2+0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==2) && ((yn2-yn1)<0)
%             plot(-vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1-0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2+0.1),str);
%             hold on;
%         end
%     end
% end
% 
% %% MOMENTO
% scala_M = 0.5;
% figure;
% for elem = 1:n_aste
%     nodo1 = ASTE(elem,2);
%     nodo2 = ASTE(elem,3);
%     xn1 = NODI(nodo1,2);
%     xn2 = NODI(nodo2,2);
%     yn1 = NODI(nodo1,3);
%     yn2 = NODI(nodo2,3);
%     dx = (xn2-xn1);
%     dy = (yn2-yn1);
%     l = sqrt(dx^2 + dy^2);
%     ca = dx/l;
%     sa = dy/l;
%     c0 = simplify(azioni_interne(elem,3,1));
%     c1 = simplify(azioni_interne(elem,3,2));
%     c2 = simplify(azioni_interne(elem,3,3));
%     c3 = simplify(azioni_interne(elem,3,4));
%     Mx ='x*ca + scala_M*(c0+c1*x+c2*x.^2+c3*x.^3)*sa+xn1';
%     My ='x*sa - scala_M*(c0+c1*x+c2*x.^2+c3*x.^3)*ca+yn1';
%     x = 0:l/100:l;
%     puntatore = [(xn2-xn1);(yn2-yn1)];
%     if puntatore(1) > 0
%         ctr = 1;
%     elseif puntatore(1) < 0
%         ctr = -1;
%     elseif puntatore(1) == 0
%         ctr = 0;
%     end
%     format rat
%     if ctr ~= 0 % se asta non è verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2);
%         axis equal;
%         hold on;
%         grid on;
%         plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         % plot del tratteggio
%         if ((ASTE(elem,4) == 1) && (ctr ==1)) || ((ASTE(elem,4) == 2) && (ctr == -1))
%             trattx = 'x*ca + 0.1*ctr*sa + xn1';
%             tratty = 'x*sa - 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ((ASTE(elem,4) == 2) && (ctr ==1)) || ((ASTE(elem,4) == 1) && (ctr == -1)) %tratteggio sinistra
%             trattx = 'x*ca - 0.1*ctr*sa + xn1';
%             tratty = 'x*sa + 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%         % vettori di punti per creazione plot e testo equazione
%         vecx = [eval(Mx)];
%         vecy = [eval(My)];
%         if (ctr == 1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1-0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2-0.05),str);
%             hold on;
%         elseif (ctr == 1) && (ASTE(elem,4)==2)
%             plot(vecx-2*(vecx(1)-xn1),vecy+2*(yn1-vecy(1)),'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1+0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2+0.05),str);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==2)
%             plot(vecx-2*(vecx(end)-xn2),vecy+2*(yn2-vecy(end)),'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1-0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2-0.05),str);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1+0.05),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2+0.05),str);
%             hold on;
%         end
%     else % se asta verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         grid on;
%         plot(xn1,yn1,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         plot(xn2,yn2,'o','MarkerFaceColor','k','MarkerEdgeColor','r');
%         % plot del tratteggio
%         if ((ASTE(elem,4) == 1) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 1) && ((yn2-yn1)<0)) % tratteggio destra
%             trattx = 'x*ca + 0.1*sa + xn1';
%             tratty = 'x*sa - 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ((ASTE(elem,4) == 2) && ((yn2-yn1)>0)) || ((ASTE(elem,4) == 2) && ((yn2-yn1)<0)) %tratteggio sinistra
%             trattx = 'x*ca - 0.1*sa + xn1';
%             tratty = 'x*sa + 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%             % vettori di punti per creazione plot
%         vecx = [eval(Mx)];
%         vecy = [eval(My)];
%         if (ASTE(elem,4)==1) && ((yn2-yn1)>0)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = sign(double(c0+c1*xn1+c2*xn1^2+c3*xn1^3))*double(sqrt((vecx(1)/scala_M-xn1)^2+(vecy(1)/scala_M-yn1)^2));
%             str = num2str(val);
%             text((xn1+0.05),(yn1+0.1),str);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3)*double(sqrt((vecx(end)-xn2)^2+(vecy(end)-yn2)^2));
%             str = num2str(val);
%             text((xn2+0.05),(yn2-0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==2) && ((yn2-yn1)>0)
%             plot(-vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1+0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2-0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==1) && ((yn2-yn1)<0)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1-0.1),(yn1-0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2-0.1),(yn2+0.1),str);
%             hold on;
%         elseif (ASTE(elem,4)==2) && ((yn2-yn1)<0)
%             plot(-vecx,vecy,'b','LineWidth',1.5);
%             val = double(c0+c1*xn1+c2*xn1^2+c3*xn1^3);
%             str = num2str(val);
%             text((xn1+0.05),(yn1-0.1),str);
%             val = double(c0+c1*xn2+c2*xn2^2+c3*xn2^3);
%             str = num2str(val);
%             text((xn2+0.05),(yn2+0.1),str);
%             hold on;
%         end
%     end
% end

%%













% scala_T = 1;
% % TAGLIO
% figure;
% for elem = 1:n_aste
%     nodo1 = ASTE(elem,2);
%     nodo2 = ASTE(elem,3);
%     xn1 = NODI(nodo1,2);
%     xn2 = NODI(nodo2,2);
%     yn1 = NODI(nodo1,3);
%     yn2 = NODI(nodo2,3);
%     dx = (xn2-xn1);
%     dy = (yn2-yn1);
%     l = sqrt(dx^2 + dy^2);
%     ca = dx/l;
%     sa = dy/l;
%     c0 = azioni_interne(elem,2,1)
%     c1 = azioni_interne(elem,2,2)
%     c2 = simplify(azioni_interne(elem,2,3))
%     c3 = simplify(azioni_interne(elem,2,4))
%     Tx ='x*ca + scala_T*(c0+c1*x+c2*x.^2+c3*x.^3)*sa+xn1';
%     Ty ='x*sa - scala_T*(c0+c1*x+c2*x.^2+c3*x.^3)*ca+yn1';
%     x = 0:l/100:l;
%     puntatore = [(xn2-xn1);(yn2-yn1)];
%     if puntatore(1) > 0
%         ctr = 1;
%     elseif puntatore(1) < 0
%         ctr = -1;
%     elseif puntatore(1) == 0
%         ctr = 0;
%     end
%     if ctr ~= 0 % se asta non è verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         % plot del tratteggio
%         if ASTE(elem,4) == 1 % tratteggio destra
%             trattx = 'x*ca + 0.1*ctr*sa + xn1';
%             tratty = 'x*sa - 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ASTE(elem,4) == 2 %tratteggio sinistra
%             trattx = 'x*ca - 0.1*ctr*sa + xn1';
%             tratty = 'x*sa + 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%         % vettori di punti per creazione plot
%         vecx = [eval(Tx)];
%         vecy = [eval(Ty)];
%         if (ctr == 1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == 1) && (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         end
%     else % se asta verticale
%         % plot asta
%         astax = 'x*ca + xn1';
%         astay = 'x*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         % plot del tratteggio
%         if ASTE(elem,4) == 1 % tratteggio destra
%             trattx = 'x*ca + 0.1*sa + xn1';
%             tratty = 'x*sa - 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ASTE(elem,4) == 2 %tratteggio sinistra
%             trattx = 'x*ca - 0.1*sa + xn1';
%             tratty = 'x*sa + 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%             % vettori di punti per creazione plot
%         vecx = [eval(Tx)];
%         vecy = [eval(Ty)];
%         if (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         end
%     end
%     
%     xtext1 = vecx(1)*ca + 0.1*ca;
%     xtext1 = double(simplify(xtext1));
%     ytext1 = vecy(1)*sa + 0.1*sa;
%     ytext1 = double(simplify(ytext1));
%     val1 = vecx(1)*sa + vecy(1)*ca;
%     val1 = double(simplify(val1));
%     xtext2 = vecx(end)*ca - 0.1*ca;
%     xtext2 = double(simplify(xtext2));
%     ytext2 = vecy(end)*sa + 0.1*sa;
%     ytext2 = double(simplify(ytext2));
%     val2 = vecx(end)*sa + vecy(end)*ca;
%     val2 = double(simplify(val2));
%     str = {num2str(val1),num2str(val2)};
%     text([xtext1 xtext2],[ytext1 ytext2],str);
% end
% 
% 
% scala_M = 0.4;
% % MOMENTO
% figure;
% for elem = 1:n_aste
%     nodo1 = ASTE(elem,2);
%     nodo2 = ASTE(elem,3);
%     xn1 = NODI(nodo1,2);
%     xn2 = NODI(nodo2,2);
%     yn1 = NODI(nodo1,3);
%     yn2 = NODI(nodo2,3);
%     dx = (xn2-xn1)*b;
%     dy = (yn2-yn1)*b;
%     l = sqrt(dx^2 + dy^2);
%     ca = dx/l;
%     sa = dy/l;
%     ca = simplify(ca)
%     sa = simplify(sa)
%     c0 = simplify(azioni_interne(elem,3,1))
%     c1 = simplify(azioni_interne(elem,3,2))
%     c2 = simplify(azioni_interne(elem,3,3))
%     c3 = simplify(azioni_interne(elem,3,4))
%     % casistiche in base al grado dell'equazione
%     if (c3 ~= 0) 
%     elseif (c3 == 0) && (c2 ~=0)
%         Mx ='(x./b)*ca + scala_M*((c0./b)+c1*(x./b)+c2*((x.^2)./(b.^2))+c3*x.^3)*sa+xn1';
%         My ='(x./b)*sa - scala_M*((c0./b)+c1*(x./b)+c2*((x.^2)./(b.^2))+c3*x.^3)*ca+yn1';
%     elseif (c3 == 0) && (c2 ==0) && (c1 ~= 0)
%         Mx ='(x./b)*ca + scala_M*((c0./b)+c1*(x./b)+c2*x.^2+c3*x.^3)*sa+xn1';
%         My ='(x./b)*sa - scala_M*((c0./b)+c1*(x./b)+c2*x.^2+c3*x.^3)*ca+yn1';
%     elseif (c3 == 0) && (c2 ==0) && (c1 == 0) && (c0 ~= 0)
%         Mx ='(x./b)*ca + scala_M*((c0./b))*sa+xn1';
%         My ='(x./b)*sa - scala_M*((c0./b))*ca+yn1';
%     elseif (c3 == 0) && (c2 ==0) && (c1 == 0) && (c0 == 0)
%         Mx ='(x./b)*ca + scala_M*(0)*sa + xn1';
%         My ='(x./b)*sa - scala_M*(0)*ca + yn1';
%     end
%     x = 0:l/100:l;
%     puntatore = [(xn2-xn1);(yn2-yn1)];
%     if puntatore(1) > 0
%         ctr = 1;
%     elseif puntatore(1) < 0
%         ctr = -1;
%     elseif puntatore(1) == 0
%         ctr = 0;
%     end
%     if ctr ~= 0 % se asta non è verticale
%         % plot asta
%         astax = '(x./b)*ca + xn1';
%         astay = '(x./b)*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         % plot del tratteggio
%         if ASTE(elem,4) == 1 % tratteggio destra
%             trattx = '(x./b)*ca + 0.1*ctr*sa + xn1';
%             tratty = '(x./b)*sa - 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ASTE(elem,4) == 2 %tratteggio sinistra
%             trattx = '(x./b)*ca - 0.1*ctr*sa + xn1';
%             tratty = '(x./b)*sa + 0.1*ctr*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%         % vettori di punti per creazione plot
%         vecx = [eval(Mx)];
%         vecy = [eval(My)];
%         if (ctr == 1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == 1) && (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ctr == -1) && (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         end
%     else % se asta verticale
%         % plot asta
%         astax = '(x./b)*ca + xn1';
%         astay = '(x./b)*sa + yn1';
%         plot(eval(astax),eval(astay),'k','LineWidth',2); 
%         axis equal;
%         hold on;
%         % plot del tratteggio
%         if ASTE(elem,4) == 1 % tratteggio destra
%             trattx = '(x./b)*ca + 0.1*sa + xn1';
%             tratty = '(x./b)*sa - 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         elseif ASTE(elem,4) == 2 %tratteggio sinistra
%             trattx = '(x./b)*ca - 0.1*sa + xn1';
%             tratty = '(x./b)*sa + 0.1*ca + yn1';
%             plot(eval(trattx),eval(tratty),'--');
%         end
%             % vettori di punti per creazione plot
%         vecx = [eval(Mx)];
%         vecy = [eval(My)];
%         if (ASTE(elem,4)==1)
%             plot(vecx,vecy,'b','LineWidth',1.5);
%             hold on;
%         elseif (ASTE(elem,4)==2)
%             plot(vecx,-vecy,'b','LineWidth',1.5);
%             hold on;
%         end
%     end
%     Mx ='(x./b)*ca + (c0+c1*x+c2*x.^2+c3*x.^3)*sa+xn1';
%     My ='(x./b)*sa - (c0+c1*x+c2*x.^2+c3*x.^3)*ca+yn1';
%     vecx = [eval(Nx)];
%     vecy = [eval(Ny)];
%     xtext1 = vecx(1)*ca + 0.1*ca;
%     xtext1 = double(simplify(xtext1));
%     ytext1 = vecy(1)*sa + 0.1*sa;
%     ytext1 = double(simplify(ytext1));
%     val1 = vecx(1)*sa + vecy(1)*ca;
%     val1 = double(simplify(val1./b))
%     xtext2 = vecx(end)*ca - 0.1*ca;
%     xtext2 = double(simplify(xtext2));
%     ytext2 = vecy(end)*sa + 0.1*sa;
%     ytext2 = double(simplify(ytext2));
%     val2 = vecx(end)*sa + vecy(end)*ca;
%     val2 = double(val2);
%     str = {num2str(val1),num2str(val2)};
%     text([xtext1 xtext2],[ytext1 ytext2],str);
% end