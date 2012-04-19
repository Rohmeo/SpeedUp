%% Independent Study - Matrix Multiply Code
close all;
figure;
core = [1,2,5,10];
time = [1.2497769, 1.2923011, 1.3035824, 1.3018376];
plot(core,time, 'b*', 'MarkerSize',10);
xlabel('Number of Cores')
ylabel('Execution Time, s')
title('10x10 Matrix Multiply Computation Speed')

%% 100x100
figure;
core = [1,2,5,10,20,50,100];
time = [1.7626656, 1.5365314, 1.4125129, 1.3581077, 1.2933241, 1.3148984, 1.3298816];
plot(core,time, 'bo');
xlabel('Number of Cores')
ylabel('Execution Time, s')
title('100x100 Matrix Multiply Computation Speed')

%% 200x200
figure;
core = [1,2,10,20,100,200];
time = [4.9463822, 3.1834122, 1.6763162, 1.4859695, 1.3796789, 1.3682464];
plot(core,time, 'bo');
xlabel('Number of Cores')
ylabel('Execution Time, s')
title('200x200 Matrix Multiply Computation Speed')

%% 500x500
figure;
core = [1,5,10,50,100,500];
time = [57.5545688, 12.6260932, 6.9646229, 2.434229, 2.4537469, 1.393408];
plot(core,time, 'bo');
xlabel('Number of Cores')
ylabel('Execution Time, s')
title('500x500 Matrix Multiply Computation Speed')

%% 1000x1000
figure;
core = [1,5,10,50,100,500,1000];
time = [449.68841, 91.649079, 46.3979794, 10.3677808, 5.926102, 4.4604124, 4.1112807];
plot(core,time, 'bo');
xlabel('Number of Cores')
ylabel('Execution Time, s')
title('10x10 Matrix Multiply Computation Speed')