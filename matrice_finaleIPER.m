function [Ke,Fe] = matrice_finaleIPER(elem,NODI,ASTE,CD)
    A = 1e8;
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
    Keprimo = zeros(6,6);
    % riempimento matrice
    Keprimo(1,1) = A/l;
    Keprimo(2,2) = 12/(l^3);
    Keprimo(3,3) = 4/l;
    Keprimo(4,4) = Keprimo(1,1);
    Keprimo(5,5) = Keprimo(2,2);
    Keprimo(6,6) = Keprimo(3,3);
    Keprimo(1,4) = -Keprimo(1,1);
    Keprimo(2,3) = 6/(l^2);
    Keprimo(2,5) = -Keprimo(2,2);
    Keprimo(2,6) = Keprimo(2,3);
    Keprimo(3,5) = -Keprimo(2,3);
    Keprimo(3,6) = 2/l;
    Keprimo(5,6) = -Keprimo(2,3);
    % elementi simmetrici uguali
    for i1 = 1:6
        for i2 = i1+1:6
            Keprimo(i2,i1) = Keprimo(i1,i2);
        end
    end
   
    % coseno e seno sistema di riferimento locale
    ca = dx/l;
    sa = dy/l;
    T0 = zeros(3,3);
    T0 = [ca -sa 0; sa ca 0; 0 0 1];
    T = [T0 zeros(3,3); zeros(3,3) T0];
    % trasformazione matrice di rigidezza
    Ke = T*Keprimo*T';
    
    % inizializzazione forze distribuite
    Feprimo = zeros(6,1);
    Fe = T*Feprimo;
end