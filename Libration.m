theta_vec = [-45 -30 -15 0 15 30 45];
tspan = [0:0.5:21600];
for i = 1:length(theta_vec)
    Param.theta_init = (i-5)*pi/18;
    simOut = sim("Libration_model.slx",tspan);
    state = simOut.State.data(:,3);
%     plot(tspan(1:7300), state(1:7300),'DisplayName',num2str(-theta_vec(i)),'Linewidth',2);
%     hold on;
    if theta_vec(i)>0
        appendage = strcat('_',num2str(abs(theta_vec(i))));
    else
        appendage = num2str(abs(theta_vec(i)));
    end
    filename_3U = strcat('Attitude_3U_',appendage,'.txt');
    filename_1U = strcat('Attitude_1U_',appendage,'.txt');

    Att = table(tspan', zeros(length(tspan),1),state, zeros(length(tspan),1));
    writetable(Att,'temp.txt','Delimiter',' ','WriteVariableNames',false);
    commandString1 = ['copy header_3U.txt+temp.txt+footer.txt','  ', filename_3U];
    commandString2 = ['copy header_1U.txt+temp.txt+footer.txt','  ', filename_1U];
    system(commandString1);
    system(commandString2);

    finalfile1 = strrep(filename_3U,'.txt','.a');
    copyfile(filename_3U,finalfile1);

    finalfile2 = strrep(filename_1U,'.txt','.a');
    copyfile(filename_1U,finalfile2);
end
grid on;
hold off;
legend;