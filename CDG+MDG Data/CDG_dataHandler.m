classdef CDG_dataHandler <handle

%     columns         index
%     trials          1
%     p1choice        2
%     p1guess         3
%     p2choice        4
%     p2guess         5
%     realsum         6
%     p1IsRight       7
%     p2IsRight       8
%     winner          9
%     p1score         10
%     p2score         11
%     p1events        12
%     p2events        13
    
    
    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
        gain
        randomKey
        finalPayoff
        
        %columns        index
        trials          =1
        p1choice        =2
        p1guess         =3
        p2choice        =4
        p2guess         =5
        realSum         =6
        p1IsRight       =7
        p2IsRight       =8
        winner          =9
        p1score         =10
        p2score         =11
        p1events        =12
        p2events        =13
    end
    
    methods
        
        %-----Constructor-----%
        function obj = CDG_dataHandler(ID1,ID2,rule,trials,gain)
            if strcmp(rule,'player1')
                obj.player1ID = ID1;
                obj.player2ID = ID2;
            else
                obj.player1ID = ID2;
                obj.player2ID = ID1;
            end
            
            obj.rule = rule;
            obj.totalTrial = trials;
            obj.result = cell(trials,13);
            obj.gain = gain;
        end
        
        %----- Updating Data -----%
        function makeSense = resMakeSense(obj, choice, guess)
            if(choice == 0 || guess == 0)
                makeSense = 0;
            else
                if(choice == 1 && guess <=4 && guess >=2)
                   makeSense = 1;
                elseif (choice == 2 && guess <=5 && guess >=3)
                   makeSense = 1;
                elseif (choice == 3 && guess <=6 && guess >=4)
                    makeSense = 1;
                else
                    makeSense = 0;
                end
            end
        end
        
        function updateData(obj,myRes,oppRes,trial)
          
            obj.result{trial,1} = trial;
            
            % p1 p2 choice guess
            if strcmp(obj.rule , 'player1')
                obj.result{trial,obj.p1choice} = myRes.choice;
                obj.result{trial,obj.p1guess} = myRes.guess;
                obj.result{trial,obj.p2choice} = oppRes.choice;
                obj.result{trial,obj.p2guess} = oppRes.guess;
                obj.result{trial,obj.p1events} = myRes.events;
                obj.result{trial,obj.p2events} = oppRes.events;
            end
            
            if strcmp(obj.rule , 'player2')
                obj.result{trial,obj.p1choice} = oppRes.choice;
                obj.result{trial,obj.p1guess} = oppRes.guess;
                obj.result{trial,obj.p2choice} = myRes.choice;
                obj.result{trial,obj.p2guess} = myRes.guess;
                obj.result{trial,obj.p1events} = oppRes.events;
                obj.result{trial,obj.p2events} = myRes.events;
            end

            if(obj.result{trial,obj.p1choice} == 0 && obj.result{trial,obj.p2choice} == 0)
                obj.result{trial,obj.p1IsRight} = 0;
                obj.result{trial,obj.p2IsRight} = 0;
                obj.result{trial,obj.realSum}   = 0;
                obj.result{trial,obj.winner}    = 0;
            elseif(obj.result{trial,obj.p1choice} == 0 && obj.result{trial,obj.p2choice} ~= 0)
                obj.result{trial,obj.p1IsRight} = 0;
                obj.result{trial,obj.p2IsRight} = 0;
                obj.result{trial,obj.realSum}   = 0;
                
                if (obj.result{trial,obj.p2guess} ~= 0)
                    obj.result{trial,obj.winner}    = 2;
                else
                    obj.result{trial,obj.winner}    = 0;
                end
            elseif(obj.result{trial,obj.p1choice} ~= 0 && obj.result{trial,obj.p2choice} == 0)
                obj.result{trial,obj.p1IsRight} = 0;
                obj.result{trial,obj.p2IsRight} = 0;
                obj.result{trial,obj.realSum}   = 0;
                
                if (obj.result{trial,obj.p1guess} ~= 0)
                    obj.result{trial,obj.winner}    = 1;
                else
                    obj.result{trial,obj.winner}    = 0;
                end
            elseif(obj.result{trial,obj.p1choice} ~= 0 && obj.result{trial,obj.p2choice} ~= 0)
                
                obj.result{trial,obj.realSum} = obj.result{trial,obj.p1choice} + obj.result{trial,obj.p2choice};
                
                if(obj.result{trial,obj.p1guess} ~= 0  && obj.result{trial,obj.p1guess} == obj.result{trial,obj.realSum})
                    obj.result{trial,obj.p1IsRight}    = 1;
                else obj.result{trial,obj.p1IsRight}   = 0; end
                
                if(obj.result{trial,obj.p2guess} ~= 0 && obj.result{trial,obj.p2guess} == obj.result{trial,obj.realSum})
                    obj.result{trial,obj.p2IsRight}    = 1;
                else obj.result{trial,obj.p2IsRight}   = 0; end
    
                if xor(obj.result{trial,obj.p1IsRight},obj.result{trial,obj.p2IsRight})
                    if(obj.result{trial,obj.p1IsRight} == 1)
                        obj.result{trial,obj.winner} = 1;
                    else
                        obj.result{trial,obj.winner} = 2;
                    end
                else
                    obj.result{trial,obj.winner} = 0;
                end
            end

            
            % update score
            if(trial == 1)
                obj.result{trial,10} = 0;
                obj.result{trial,11} = 0;
            else
                obj.result{trial,10} = obj.result{trial-1,10};
                obj.result{trial,11} = obj.result{trial-1,11};
            end
            
            
            if( obj.result{trial,obj.winner} == 1) % p1 win
                obj.result{trial,10} = obj.result{trial,10} + 1;
            end
            
            if( obj.result{trial,obj.winner} == 2) % p2 win
                obj.result{trial,11} = obj.result{trial,11} + 1;
            end
            
        end
        
        function data = getResult(obj,trial)
            
            if strcmp(obj.rule , 'player1')
                data.yourChoice = obj.result{trial,obj.p1choice};
                data.yourGuess  = obj.result{trial,obj.p1guess};
                data.oppChoice  = obj.result{trial,obj.p2choice};
                data.oppGuess   = obj.result{trial,obj.p2guess};
                data.realSum    = obj.result{trial,obj.realSum};
                data.yourScore  = obj.result{trial,obj.p1score};
                data.oppScore   = obj.result{trial,obj.p2score};
                
                if(obj.result{trial,obj.winner} == 1) data.winner = 'WIN'; end
                if(obj.result{trial,obj.winner} == 2) data.winner = 'LOSE'; end
                if(obj.result{trial,obj.winner} == 0) data.winner = 'DRAW'; end
            end
            
            if strcmp(obj.rule , 'player2')
                data.yourChoice = obj.result{trial,obj.p2choice};
                data.yourGuess  = obj.result{trial,obj.p2guess};
                data.oppChoice  = obj.result{trial,obj.p1choice};
                data.oppGuess   = obj.result{trial,obj.p1guess};
                data.realSum    = obj.result{trial,obj.realSum};
                data.yourScore  = obj.result{trial,obj.p2score};
                data.oppScore   = obj.result{trial,obj.p1score};
                
                if(obj.result{trial,obj.winner} == 2) data.winner = 'WIN'; end
                if(obj.result{trial,obj.winner} == 1) data.winner = 'LOSE'; end
                if(obj.result{trial,obj.winner} == 0) data.winner = 'DRAW'; end
            end
        end
        
        function finalScore = setKeyGetScore(obj,key)
            obj.randomKey = mod(key,3)+1;
            temp = 0;
            penalty = 0;
            for i = 1:obj.totalTrial
                if(strcmp(obj.rule,'player1'))
                    if(obj.result{i,obj.p1choice} == 0 || obj.result{i,obj.p1guess} == 0)
                        penalty = penalty+1;
                    end
                end
                
                if(strcmp(obj.rule,'player2'))
                    if(obj.result{i,obj.p2choice} == 0 || obj.result{i,obj.p2guess} == 0)
                        penalty = penalty+1;
                    end
                end
            end
            
            
            for i = obj.randomKey:3:obj.totalTrial
                if(strcmp(obj.rule,'player1'))
                    temp = temp + obj.result{i,obj.p1IsRight};
                end
                if(strcmp(obj.rule,'player2'))
                    temp = temp + obj.result{i,obj.p2IsRight};
                end
                
            end
            
            finalScore = temp - penalty;
            obj.finalPayoff = finalScore;
        end
        
        function logStatus(obj,trial)
            fprintf('=================================================\n');
            fprintf('Trial          %d\n',trial);
            
            if strcmp(obj.rule , 'player1')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: win\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: lose\n'); end
                fprintf('Result:')
                fprintf('Your Score: %d\n',obj.result{trial,10});
                fprintf('Opp Score: %d\n',obj.result{trial,11});
            end
            
            if strcmp(obj.rule , 'player2')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: lose\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: win\n'); end
                fprintf('Your Score: %d\n',obj.result{trial,11});
                fprintf('Opp Score: %d\n',obj.result{trial,10});
            end
        end
        
        
        %----- Writing and Loading -----%
        function saveToFile(obj)
            result = obj;
            filename = strcat('./RawData/CDG',datestr(now,'YYmmDD'),'_',datestr(now,'hhMM'),'_',obj.player1ID,'.mat');
            save(filename,'result');
            fprintf('Data saved to file.\n');
        end
        
        function data = loadData(obj,filename)
            rawData = load(filename);
            data = rawData.result;
        end
        
    end
    
end

