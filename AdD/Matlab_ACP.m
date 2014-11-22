%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      TP d'Analyse de Données / VERGEZ Valentin - APPERCÉ Pierre      %
%     Etude de données sur groupes de voitures et leur consomations    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fonction procédant à l'analyse complète des données
%function Matlab_ACP()

%% Initialisation
    % Clean de l'environnment
    close all;
    clear;
    clc;
    fprintf('TP d''Analyse de Données - APPERCE/VERGEZ\n\n');
    
    % Lecture des données d'entrées
    Donnees = textread('auto_tp.txt');

    % Découpage des variables
    mgp = Donnees(:,1); 
    cylinders = Donnees(:,2); 
    displacement = Donnees(:,3); 
    horsepower = Donnees(:,4); 
    weight = Donnees(:,5); 
    acceleration = Donnees(:,6); 
    year = Donnees(:,7); 
    origin = Donnees(:,8); 
    zero = Donnees(:,9); 

    % Donnes correspondant à la matrice de données utiles 
    %(on ne garde que les variables continues)
    % NB : Les variables discrètes pourront servir de variables supplémentaires
    Donnees = Donnees(:,[1,3:6]);

%% Normalisation de la matrice
    % Calcul de la moyenne et la variance de chaque colonne
    Moy = mean(Donnees);
    Var = std(Donnees);

    % Centrer les données
    Donnees_centrees = horzcat(Donnees(:,1)- Moy(1),Donnees(:,2)- Moy(2),Donnees(:,3)- Moy(3),Donnees(:,4)- Moy(4),Donnees(:,5)- Moy(5));
    % Réduire les données
    Donnees_centrees_reduite = horzcat(Donnees_centrees(:,1)./ Var(1),Donnees_centrees(:,2)./ Var(2),Donnees_centrees(:,3)./ Var(3),Donnees_centrees(:,4)./ Var(4),Donnees_centrees(:,5)./ Var(5));

    % NB : Pour vérifier que les données sont bien centrées et réduite on
    % peut calculer la moyenne et la variance, on doit logiquement obtenir
    % une moyenne de 0 et une variance de 1
    
%% ACP : Analyse en Composantes Principales | \label{MatLab:ACP} |
    % Calcul de la matrice de corrélation
    Mcorrelation =(Donnees_centrees_reduite'*Donnees_centrees_reduite);

    % Calcul du vecteur propre et des valeurs propres
    [ ~, S, U2]=svd(Mcorrelation);
    I=diag(S);          % Valeurs propres

    % Matrice de coordonnées des individus sur les axes
    Mcoord = Donnees_centrees_reduite*U2;

    % Determination des axes à conserver
    Interet = (I ./ sum(I))*100;
    figure('Name','Graphe d''intérêt des axes','NumberTitle','off')
    bar(Interet);

    % Identification des classe à l'aide des variables supplémentaites
    figure('Name','Nuage de points colorés par nombre de cylindres et origines','NumberTitle','off')
    gscatter_ima5(Mcoord(:,1),Mcoord(:,2),cylinders,origin);

%% Prédiction du mpg en fonctions des autres variables | \label{MatLab:prediction} |
    % le vecteur d'estimation
    Demi_Donnees = Donnees(1:21,2:5);
    [Coeff] = Donnees(1:21,1)'*Demi_Donnees*(inv(Demi_Donnees'*Demi_Donnees));

    % On calcul ensuite les mpg estimés sur la seconde moitié des données
    [mpg_estim] = Coeff*(Donnees(22:43,2:5)');
    mpg_estim = mpg_estim';
    
    % On vérifie ensuite leur pertinence (en pourcentage)
    res1 = ((Donnees(22:43,1)-mpg_estim).^2)./(Donnees(22:43,1).^2);
    res2 = sum(res1)/(43-22)*100;
    fprintf('Erreur de l''estimation : %.0f %%\n',res2);
    
    figure('Name','Valeurs réelles et valeurs estimées','NumberTitle','off')
    plot(Donnees(22:43,1),'b');hold on; plot(mpg_estim,'r');
    title('Réprésentation de l''estimation et des valeurs réelles');

%end