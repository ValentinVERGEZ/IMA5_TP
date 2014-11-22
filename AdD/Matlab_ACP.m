%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      TP d'Analyse de Donn�es / VERGEZ Valentin - APPERC� Pierre      %
%     Etude de donn�es sur groupes de voitures et leur consomations    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fonction proc�dant � l'analyse compl�te des donn�es
%function Matlab_ACP()

%% Initialisation
    % Clean de l'environnment
    close all;
    clear;
    clc;
    fprintf('TP d''Analyse de Donn�es - APPERCE/VERGEZ\n\n');
    
    % Lecture des donn�es d'entr�es
    Donnees = textread('auto_tp.txt');

    % D�coupage des variables
    mgp = Donnees(:,1); 
    cylinders = Donnees(:,2); 
    displacement = Donnees(:,3); 
    horsepower = Donnees(:,4); 
    weight = Donnees(:,5); 
    acceleration = Donnees(:,6); 
    year = Donnees(:,7); 
    origin = Donnees(:,8); 
    zero = Donnees(:,9); 

    % Donnes correspondant � la matrice de donn�es utiles 
    %(on ne garde que les variables continues)
    % NB : Les variables discr�tes pourront servir de variables suppl�mentaires
    Donnees = Donnees(:,[1,3:6]);

%% Normalisation de la matrice
    % Calcul de la moyenne et la variance de chaque colonne
    Moy = mean(Donnees);
    Var = std(Donnees);

    % Centrer les donn�es
    Donnees_centrees = horzcat(Donnees(:,1)- Moy(1),Donnees(:,2)- Moy(2),Donnees(:,3)- Moy(3),Donnees(:,4)- Moy(4),Donnees(:,5)- Moy(5));
    % R�duire les donn�es
    Donnees_centrees_reduite = horzcat(Donnees_centrees(:,1)./ Var(1),Donnees_centrees(:,2)./ Var(2),Donnees_centrees(:,3)./ Var(3),Donnees_centrees(:,4)./ Var(4),Donnees_centrees(:,5)./ Var(5));

    % NB : Pour v�rifier que les donn�es sont bien centr�es et r�duite on
    % peut calculer la moyenne et la variance, on doit logiquement obtenir
    % une moyenne de 0 et une variance de 1
    
%% ACP : Analyse en Composantes Principales | \label{MatLab:ACP} |
    % Calcul de la matrice de corr�lation
    Mcorrelation =(Donnees_centrees_reduite'*Donnees_centrees_reduite);

    % Calcul du vecteur propre et des valeurs propres
    [ ~, S, U2]=svd(Mcorrelation);
    I=diag(S);          % Valeurs propres

    % Matrice de coordonn�es des individus sur les axes
    Mcoord = Donnees_centrees_reduite*U2;

    % Determination des axes � conserver
    Interet = (I ./ sum(I))*100;
    figure('Name','Graphe d''int�r�t des axes','NumberTitle','off')
    bar(Interet);

    % Identification des classe � l'aide des variables suppl�mentaites
    figure('Name','Nuage de points color�s par nombre de cylindres et origines','NumberTitle','off')
    gscatter_ima5(Mcoord(:,1),Mcoord(:,2),cylinders,origin);

%% Pr�diction du mpg en fonctions des autres variables | \label{MatLab:prediction} |
    % le vecteur d'estimation
    Demi_Donnees = Donnees(1:21,2:5);
    [Coeff] = Donnees(1:21,1)'*Demi_Donnees*(inv(Demi_Donnees'*Demi_Donnees));

    % On calcul ensuite les mpg estim�s sur la seconde moiti� des donn�es
    [mpg_estim] = Coeff*(Donnees(22:43,2:5)');
    mpg_estim = mpg_estim';
    
    % On v�rifie ensuite leur pertinence (en pourcentage)
    res1 = ((Donnees(22:43,1)-mpg_estim).^2)./(Donnees(22:43,1).^2);
    res2 = sum(res1)/(43-22)*100;
    fprintf('Erreur de l''estimation : %.0f %%\n',res2);
    
    figure('Name','Valeurs r�elles et valeurs estim�es','NumberTitle','off')
    plot(Donnees(22:43,1),'b');hold on; plot(mpg_estim,'r');
    title('R�pr�sentation de l''estimation et des valeurs r�elles');

%end