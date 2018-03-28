tic
clearvars; close all;
rng('default');

% array containing the randomly generated genes 
G = zeros(243,200); 

%prepare Max's location array
maxRow = 2;
maxColumn = 2;
maxLocation = [2; 2];


% how Max is scored
thisMoveScore = 0;
NextMove = 0;
NextMoveInd = 0;
fitness = zeros(200,2);
sortedFitness = zeros(200,3);
maxFitness = zeros(1000,1);
roundScore = zeros(100,200);

%breeding variables
children1 = zeros(243,100);
children2 = zeros(243,100);
candidateParents = zeros(15,2);

for i=1:200   % for loop generates 200 hundred random genes  
    for j=1:1:243
        G(j,i) = floor(6*rand)+1;
    end
end

Theatre = zeros(12,12,100); %array representing the theatre 

for i=1:100
    
for j=1:12 % house keeping - ensures the walls of the theatre are assigned 2s
    Theatre(1,j,i) = 2;
    Theatre(j,1,i) = 2;
    Theatre(12,j,i) = 2;
    Theatre(j,12,i)= 2;
end

end

p = 0.5; % the chance that rubbish will be placed in a random cell

for i=1:100
for j=2:1:11 %for loop places rubbish in random cells based on probability p
    
    for k=2:1:11
       rubbish = rand;
       if rubbish < p
           Theatre(j,k,i) = 1;
       end
       %r=r+1;
    end
    %c=c+1;
end
end

%image(Theatre);
TheatreCopy = zeros(12,12);

currentLocale = [0,0,0,0,0]; %initialise the array holding were the robot is about to look

for generations = 1:1000

for strat = 1:200
    disp(strat)
    
for dist = 1:100
  
    
    currentScore = 0;
    
    for i=1:12
        for j=1:12
            TheatreCopy(i,j) = Theatre(i,j,dist);
        end
    end
    
   for numMoves=1:200

% Max looks around to determine his locale
currentLocale(1) = TheatreCopy(maxRow-1,maxColumn);
currentLocale(2) = TheatreCopy(maxRow+1,maxColumn);
currentLocale(3) = TheatreCopy(maxRow,maxColumn+1);
currentLocale(4) = TheatreCopy(maxRow,maxColumn-1);
currentLocale(5) = TheatreCopy(maxRow,maxColumn);

NextMoveInd = 0;

% To determine the next move Max makes we convert the Locale into a 
% base 3 binary number and use that as the index for the next move
if currentLocale(1) == 1
    NextMoveInd = 81;
elseif currentLocale(1) == 2
    NextMoveInd = 162;
end
if currentLocale(2) == 1
    NextMoveInd = NextMoveInd + 27;
elseif currentLocale(2) == 2
    NextMoveInd = NextMoveInd + 54;
end
if currentLocale(3) == 1
    NextMoveInd = NextMoveInd + 9;
elseif currentLocale(3) == 2
    NextMoveInd = NextMoveInd + 18;
end
if currentLocale(4) == 1
    NextMoveInd = NextMoveInd + 3;
elseif currentLocale(4) == 2
    NextMoveInd = NextMoveInd + 6;
end
if currentLocale(5) == 1
    NextMoveInd = NextMoveInd + 1;
end

if NextMoveInd == 0
    NextMoveInd = 243;
end

% Fetch the next move using the index
NextMove = G(NextMoveInd,strat);

% if a random move was selected then Max does something random
if NextMove == 6
    NextMove = floor(5*rand)+1;
end

% scoring Max and update the map if he picks up rubbish well
if currentLocale(1) == 2 && NextMove == 1
    thisMoveScore = -5;
elseif currentLocale(2) == 2 && NextMove == 2
    thisMoveScore = -5;
elseif currentLocale(3) == 2 && NextMove == 3
    thisMoveScore = -5;
elseif currentLocale(4) == 2 && NextMove ==4
    thisMoveScore = -5;
elseif currentLocale(5) == 1 && NextMove == 5
    thisMoveScore = 10; TheatreCopy(maxRow, maxColumn) = 0;
elseif currentLocale(5) == 0 && NextMove == 5
    thisMoveScore = -1;
end

currentScore = thisMoveScore + currentScore;
thisMoveScore = 0;

% updating Max's location for the next move, unless he crashed into a wall
if NextMove == 1 && currentLocale(1) ~=2
    maxRow = maxRow -1;
elseif NextMove == 2 && currentLocale(2) ~=2
    maxRow = maxRow +1;
elseif NextMove == 3 && currentLocale(3) ~=2
    maxColumn = maxColumn +1;
elseif NextMove == 4 && currentLocale(4) ~=2
    maxColumn = maxColumn -1;
end

    maxLocation = [maxRow, maxColumn];

   end
   
   roundScore(dist,strat) = currentScore;
   
end
 
   % collect Max's scores and give each strategy a fitness rating
   fitness(strat,1) = mean(roundScore(1:100,strat));
   fitness(strat,2) = strat;
 
end

% Now Max has finished cleaning we prepare the strategies he used for 
% breeding
newParentIndex = [0,0];

% sort the fitness values and then breed them to get 200 children
%sortedFitness = sortrows(fitness,1,'descend'); sortedFitness(1:200,3) = 1:200;
maxFitness(generations,1) = max(fitness(1:200,1));
%sortedFitness(1,1);

% Begin the breeding process, 100 breeds produce 200 children
for breed=1:100
  
  % Picking 2 parents using tournament selection, choose 15 random 
  % strategies as candidate parents and then pick the best of these as
  % the parent
  for i=1:2
      
        for j=1:15
            candidateParents(j,2) = floor(rand*200)+1;
            candidateParents(j,1) = fitness(candidateParents(j,2),1);
        end
        
    sortedCandParents = sortrows(candidateParents,1,'ascend');
    newParentIndex(1,i) = sortedCandParents(15,2);
    
  end
    
  % The two proud parents
  parent1 = G(1:243,newParentIndex(1,1));
  parent2 = G(1:243,newParentIndex(1,2));
  
  % Choose a crossover point randomly
  crossoverPoint = floor(rand*243)+1;
  
  % The two sets of 100 bundles of joy ready to be placed into the new population
  children1(1:243,breed) = vertcat(parent1(1:crossoverPoint), parent2(crossoverPoint+1:243)); 
  children2(1:243,breed) = vertcat(parent2(1:crossoverPoint), parent1(crossoverPoint+1:243));
  
end
    % The new population, comprised of the 200 children ready to 
    % go again, Godspeed Max.
    G = horzcat(children1, children2);
    
    % Mutate the new population slightly to improve on the parents
for i = 1:200
    for j=1:243
        if rand < 0.0099
            G(j,i) = floor(6*rand)+1;
        end
    end
end
    
    disp(maxFitness(generations));
    plot(generations,maxFitness(generations),'x')
    hold on
    drawnow;

end
    
toc
    

    





