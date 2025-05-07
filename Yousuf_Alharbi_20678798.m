% Yousef Alharbi
% egyya4@nottingham.ac.uk


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]
a = arduino('COM3', 'Uno');  
for k = 1:10
    writeDigitalPin(a, 'D9', 1);  % LED ON
    pause(0.5);
    writeDigitalPin(a, 'D9', 0);  % LED OFF
    pause(0.5);
end
clear a

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

a = arduino('COM3', 'Uno');           % Replace with your Arduino port
duration = 600;                       % 10 minutes
pin = 'A0';                           % Analog pin
V0 = 0.5; TC = 0.01;                  % MCP9700A constants

temps = zeros(1, duration + 1);

for t = 0:duration
    V = readVoltage(a, pin);
    temps(t + 1) = (V - V0) / TC;     % Temp in °C
    pause(1);                         % 1-second delay
end

% Plot
plot(0:duration, temps, 'b');
xlabel('Time (s)'); ylabel('Temperature (°C)');
title('Cabin Temperature');

% Stats
tmin = min(temps); tmax = max(temps); tavg = mean(temps);

% Console and file output
logfile = fopen('cabin_temperature.txt', 'w');
fprintf(logfile, 'Data logging initiated - %s\nLocation - Nottingham\n\n', datestr(now, 'dd/mm/yyyy'));

for i = 0:10
    idx = i*60 + 1;
    fprintf(logfile, 'Minute\t\t%d\nTemperature \t%.2f C\n\n', i, temps(min(idx, end)));
end

fprintf(logfile, 'Max temp\t%.2f C\nMin temp\t%.2f C\nAverage temp\t%.2f C\n\nData logging terminated\n', tmax, tmin, tavg);
fclose(logfile);
clear a

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

a = arduino('COM3', 'Uno'); 
temp_monitor(a);             % Call Task 2 function
clear a

%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]

a = arduino('COM3', 'Uno'); % Replace with your port

% Constants
V0 = 0.5; TC = 0.01;
sensorPin = 'A0';
greenLED = 'D9'; yellowLED = 'D10'; redLED = 'D11';
configurePin(a, greenLED, 'DigitalOutput');
configurePin(a, yellowLED, 'DigitalOutput');
configurePin(a, redLED, 'DigitalOutput');

duration = 600;                   % 10 minutes
sampleInterval = 1;
futureSeconds = 300;             % Predict 5 min ahead
temps = zeros(1, duration);      % Full temperature array
smoothedTemps = zeros(1, duration); % For smoothed values

window = 15; % Smoothing over last 15 readings

figure;
h = plot(temps, 'b'); grid on;
xlabel('Time (s)'); ylabel('Temperature (°C)');
title('Smoothed Temperature and Prediction');
ylim([10 35]); xlim([0 duration]);

for t = 2:duration
    % Read and convert
    V = readVoltage(a, sensorPin);
    T = (V - V0) / TC;
    temps(t) = T;

    % Smooth using last 15 readings
    idxStart = max(1, t - window + 1);
    smoothedTemps(t) = mean(temps(idxStart:t));
    T_smoothed = smoothedTemps(t);

    % Calculate smoothed rate of change
    dT = smoothedTemps(t) - smoothedTemps(max(1, t - 1));
    rate = dT / sampleInterval;
    ratePerMin = rate * 60;

    % Predict future temperature
    T_pred = T_smoothed + rate * futureSeconds;

    % Display info
    fprintf('Time: %ds | Temp: %.2f°C | Smoothed: %.2f°C | dT/dt: %.2f°C/min | Predicted: %.2f°C\n', ...
            t, T, T_smoothed, ratePerMin, T_pred);

    % LED logic
    if abs(ratePerMin) < 4
        writeDigitalPin(a, greenLED, 1);
        writeDigitalPin(a, yellowLED, 0);
        writeDigitalPin(a, redLED, 0);
    elseif ratePerMin > 4
        writeDigitalPin(a, greenLED, 0);
        writeDigitalPin(a, yellowLED, 0);
        writeDigitalPin(a, redLED, 1);
    else
        writeDigitalPin(a, greenLED, 0);
        writeDigitalPin(a, yellowLED, 1);
        writeDigitalPin(a, redLED, 0);
    end

    % Update live plot
    set(h, 'YData', smoothedTemps);
    drawnow;
    pause(sampleInterval);
end

% Cleanup
writeDigitalPin(a, greenLED, 0);
writeDigitalPin(a, yellowLED, 0);
writeDigitalPin(a, redLED, 0);


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

%% This project was a great chance to put what I learned in MATLAB to use with real hardware.
% Getting the Arduino to connect to MATLAB was a bit tricky at first—I had to figure out
% which port it was on and make sure the support package was properly installed.
% But once that was done, things got easier.

% Making the LEDs blink based on temperature readings was fun to implement.
% The hard part was making sure the timing worked well with the live plot.
% I had to play around with pause() and drawnow to get smooth updates.

% Predicting future temperatures was more technical and made me think more carefully
% about math and logic. I had to calculate how fast the temperature was changing and
% adjust the LED behavior accordingly.

% I made sure to keep my code clean by writing separate functions, and I used Git to
% track changes and back things up along the way. It really helped when debugging.

% One thing I noticed was that the temperature sensor sometimes gave jumpy readings.
% I think this could be improved by filtering the data or using a better sensor.

% If I kept working on this, I’d add a simple user interface and maybe some more sensors.
% I definitely feel more confident using MATLAB and working with embedded systems after this.


%% TASK 5 - COMMENTING, VERSION CONTROL AND PROFESSIONAL PRACTICE [15 MARKS]

% No need to enter any answershere, but remember to:
% - Comment the code throughout.
% - Commit the changes to your git repository as you progress in your programming tasks.
% - Hand the Arduino project kit back to the lecturer with all parts and in working order.