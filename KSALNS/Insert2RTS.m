function [minAddCost,NewR,minObj,minSTime,minSDis] = Insert2RTS(Order1,r,k,Parameter,Setting)
if isempty(r)
    NewR = [Order1 Order1+Parameter.PickOrder];
    [NewObjs,NewSTime,NewSDis] = CalObjective(NewR,k,Parameter,Setting);
    R_Q = cumsum(Parameter.MerCus_Demand(NewR));
    if all(R_Q<=Parameter.Cap(k),'all') && NewSDis <= Parameter.TimeUp(k)
        minAddCost = NewObjs;
        minObj     = NewObjs;
        minSTime   = NewSTime;
        minSDis    = NewSDis;
    else
        minAddCost = Inf;
        minObj     = 0;
        minSTime   = 0;
        minSDis    = 0;
    end
else
    NewR = r;
    minAddCost = Inf;
    minObj    = 0;
    minSTime   = 0;
    minSDis    = 0;
    NewC = Parameter.Customers2Orders(r);
    NewC1 = unique(NewC,'stable');
    indexC1 = find(NewC==Parameter.Customers2Orders(Order1),1,'last');
    if isempty(indexC1)
        for j1 = 0:length(NewC1)
            if j1==0
                Pos1 = 0;
            else
                Pos1 = find(NewC==NewC1(j1),1,'last');
            end
            for j2 = j1:length(NewC1)
                if j2 == 0
                    Pos2 = 0;
                else
                    Pos2 = find(NewC==NewC1(j2),1,'last');
                end
                Newr = [r(1:Pos1),Order1,r(Pos1+1:Pos2),Order1+Parameter.PickOrder,r(Pos2+1:end)];
                [NewObj,NewSTime,NewSDis] = CalObjective(Newr,k,Parameter,Setting);
                R_Q = cumsum(Parameter.MerCus_Demand(Newr));
                if all(R_Q<=Parameter.Cap(k),'all') && NewSDis <= Parameter.TimeUp(k)
                    %雇佣车辆不考虑禁忌
                    if k > Parameter.ODnum 
                        AddCost =  NewObj - CalObjective(r,k,Parameter,Setting);
                        if AddCost < minAddCost
                            minAddCost = AddCost;
                            NewR = Newr;
                            minObj = NewObj;
                            minSTime = NewSTime;
                            minSDis = NewSDis;
                        end
                    else
                        Order1Index  = find(Newr == Order1);
                        Order1nIndex = find(Newr == Order1 + Parameter.PickOrder);
                        if Order1Index == 1 && Order1nIndex == length(Newr)
                            if Parameter.TabuList(k+2*Parameter.PickOrder,Order1) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex-1),Newr(Order1nIndex)) == 0
                                AddCost =  NewObj - CalObjective(r,k,Parameter,Setting);
                                if AddCost < minAddCost
                                    minAddCost = AddCost;
                                    NewR = Newr;
                                    minObj = NewObj;
                                    minSTime = NewSTime;
                                    minSDis  = NewSDis;
                                end
                            end
                        elseif Order1Index == 1 && Order1nIndex <length(Newr)
                            if Parameter.TabuList(k+2*Parameter.PickOrder,Order1) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex-1),Newr(Order1nIndex)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex),Newr(Order1nIndex+1)) == 0
                                AddCost =  NewObj - CalObjective(r,k,Parameter,Setting);
                                if AddCost < minAddCost
                                    minAddCost = AddCost;
                                    NewR = Newr;
                                    minObj = NewObj;
                                    minSTime = NewSTime;
                                    minSDis  = NewSDis;
                                end
                            end
                        elseif Order1Index ~=1 && Order1nIndex == length(Newr)
                            if Parameter.TabuList(Newr(Order1Index-1),Newr(Order1Index)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1Index),Newr(Order1Index+1)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex-1),Newr(Order1nIndex)) == 0
                                AddCost =  NewObj - CalObjective(r,k,Parameter,Setting);
                                if AddCost < minAddCost
                                    minAddCost = AddCost;
                                    NewR = Newr;
                                    minObj = NewObj;
                                    minSTime = NewSTime;
                                    minSDis  = NewSDis;
                                end
                            end
                        elseif Order1Index ~=1 && Order1nIndex < length(Newr)
                            if Parameter.TabuList(Newr(Order1Index-1),Newr(Order1Index)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1Index),Newr(Order1Index+1)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex-1),Newr(Order1nIndex)) == 0 ...
                                    || Parameter.TabuList(Newr(Order1nIndex),Newr(Order1nIndex+1)) == 0
                                AddCost =  NewObj - CalObjective(r,k,Parameter,Setting);
                                if AddCost < minAddCost
                                    minAddCost = AddCost;
                                    NewR = Newr;
                                    minObj = NewObj;
                                    minSTime = NewSTime;
                                    minSDis  = NewSDis;
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        indexC2 = find(NewC==Parameter.Customers2Orders(Order1)+Parameter.PickCustomer,1,'last');
        Newr = [r(1:indexC1),Order1,r(indexC1+1:indexC2),Order1+Parameter.PickOrder,r(indexC2+1:end)];
        R_Q = cumsum(Parameter.MerCus_Demand(Newr));
        if all(R_Q<=Parameter.Cap(k),'all')
            minAddCost = 0;
            NewR = Newr;
            [minObj,minSTime,minSDis] = CalObjective(NewR,k,Parameter,Setting);
        end
    end
end
end