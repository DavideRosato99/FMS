function [Ke,Fe] = matrice_finale(elem,NODI,ASTE,CD)
    syms q b E A I R
    assume(b,'integer');
    assume(b>0);
    nodo1 = ASTE(elem,2);
    nodo2 = ASTE(elem,3);
    xn1 = NODI(nodo1,2);
    xn2 = NODI(nodo2,2);
    yn1 = NODI(nodo1,3);
    yn2 = NODI(nodo2,3);
    dx = (xn2-xn1);
    dy = (yn2-yn1);
    l = sqrt(dx^2 + dy^2);
    
    % inizializzazione matrice simbolica
    Keprimo = sym(zeros(6,6));
    % riempimento matrice
    Keprimo(1,1) = E*A/l;
    Keprimo(2,2) = 12*E*I/(l^3);
    Keprimo(3,3) = 4*E*I/l;
    Keprimo(4,4) = Keprimo(1,1);
    Keprimo(5,5) = Keprimo(2,2);
    Keprimo(6,6) = Keprimo(3,3);
    Keprimo(1,4) = -Keprimo(1,1);
    Keprimo(2,3) = 6*(E*I)/(l^2);
    Keprimo(2,5) = -Keprimo(2,2);
    Keprimo(2,6) = Keprimo(2,3);
    Keprimo(3,5) = -Keprimo(2,3);
    Keprimo(3,6) = 2*(E*I)/l;
    Keprimo(5,6) = -Keprimo(2,3);
    % elementi simmetrici uguali
    for i1 = 1:6
        for i2 = i1+1:6
            Keprimo(i2,i1) = Keprimo(i1,i2);
        end
    end
    Keprimo
    % coseno e seno sistema di riferimento locale
    ca = dx/l;
    sa = dy/l;
    T0 = sym(zeros(3,3));
    T0 = [ca -sa 0; sa ca 0; 0 0 1];
    T = [T0 sym(zeros(3,3)); sym(zeros(3,3)) T0]
    % trasformazione matrice di rigidezza
    T
    Ke = T*Keprimo*T'
    
    % inizializzazione forze distribuite
    Feprimo = sym(zeros(6,1));
    if size(CD,1) > 0
        pp = CD(elem,2);
        qq = (CD(elem,3)-pp);
        fv = pp*(l/2);
        fm = pp*(l^2/12);
        Feprimo(2) = fv;
        Feprimo(3) = fm;
        Feprimo(5) = fv;
        Feprimo(6) = -fm;
        Feprimo(2) = Feprimo(2)+(3/20)*qq*l;
        Feprimo(3) = Feprimo(3)+(1/30)*qq*(l^2);
        Feprimo(5) = Feprimo(5)+(7/20)*qq*l;
        Feprimo(6) = Feprimo(6)-(1/20)*qq*(l^2);
    end
    Fe = T*Feprimo;
    
end