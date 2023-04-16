%% read tables
for i=1:5
    TT{i}=xlsread(['D:\2nd degree\year 4 sem 1\modeling nets\Neural Coding\TT' num2str(i) '.xlsx']);
end
StimTime=xlsread('D:\2nd degree\year 4 sem 1\modeling nets\Neural Coding\StimTime.xlsx');

%% calculate action potentials time referenced to trials 
APtimes=nan(5,size(StimTime,1),2500);
for i=1:5
    for j=1:size(StimTime,1)
       temp=TT{i}(TT{i}>StimTime(j,1) & TT{i}<=((StimTime(j,1))+20000));
       APtimes(i,j,1:length(temp))=temp-StimTime(j,1);
    end
end

%% figures
for i=1:5
    figure()
    sgtitle(['Neuron #', num2str(i)]); 
    
    subplot(2,1,1)
    histogram(APtimes(i,:,:),20)
    hold on
    xlim([0 20000]);
    xlabel('time (ms)');
    ylabel('number of spikes');
    plot([0 10000],[-1,-1],'b:','LineWidth',1.5);
    hold on
    plot([10000 20000],[-1,-1],'r:','LineWidth',1.5);
    hold on
    
    subplot(2,1,2)
    for j=1:length(StimTime);
        scatter(squeeze(APtimes(i,j,:)),ones(2500,1)*j,2,'filled');
        hold on
    end
    xlabel('time (ms)');
    ylabel('trial');
    xlim([0 20000]);
    plot([0 0 10000],[115 -1,-1],'b:','LineWidth',1.5);
    hold on
    plot([10000 10000 20000],[115 -1,-1],'r:','LineWidth',1.5);
    legend('Light Off','Light On');
end

%% filter
% to filter we will you 'conv' for convolving the original distribution with
% a kernel. first we will use a rectangle and then a gaussian. 

%count spikes
KerSize=5;
binsize=20;
x=[1:binsize]*(20000/binsize);
for i=1:5
    previous=0;
    for bin=1:binsize
        APcount(i,bin)=sum(sum(APtimes(i,:,:)<=x(bin) & APtimes(i,:,:)>=previous));
        previous=x(bin);
    end
    
    %use a rectangular kernel
    Rkernel=ones(KerSize,1)/KerSize;
    APFiltRec(i,:)=conv(APcount(i,:),Rkernel,'same');
    
    %use a gaussian kernel
    Gkernel=normpdf(1:KerSize,mean(1:KerSize),1);
    APFiltGauss(i,:)=conv(APcount(i,:),Gkernel,'same');
end

for i=1:5
    figure()
    sgtitle(['Neuron #', num2str(i)]); 
    subplot(2,1,1)
    bar(x-((20000/binsize)/2),APFiltRec(i,:))
    hold on
    title('Rectangular Kernel')
    xlim([0 20000]);
    xlabel('time (ms)');
    ylabel('number of spikes');
    plot([0 10000],[-1,-1],'b:','LineWidth',1.5);
    hold on
    plot([10000 20000],[-1,-1],'r:','LineWidth',1.5);
    hold on
    
    subplot(2,1,2)
    bar(x-((20000/binsize)/2),APFiltGauss(i,:))
    hold on
    title('Gaussian Kernel')
    xlim([0 20000]);
    xlabel('time (ms)');
    ylabel('number of spikes');
    plot([0 10000],[-1,-1],'b:','LineWidth',1.5);
    hold on
    plot([10000 20000],[-1,-1],'r:','LineWidth',1.5);
    hold on
    legend('Spike Count','Light Off','Light On');
end