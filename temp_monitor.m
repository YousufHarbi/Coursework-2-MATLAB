function temp_monitor(a)
% TEMP_MONITOR Monitors cabin temperature and controls LEDs.
% a - Arduino object from main script (e.g., a = arduino('COM4', 'Uno'))

% Define constants
V0 = 0.5;            % Voltage at 0°C for MCP9700A
TC = 0.01;           % Temp. coefficient in V/°C
duration = 600;      % Monitor for 10 minutes
sensorPin = 'A0';    % Analog pin for thermistor

% Define LED pins
greenLED = 'D9';
yellowLED = 'D10';
redLED = 'D11';

% Setup pins
configurePin(a, greenLED, 'DigitalOutput');
configurePin(a, yellowLED, 'DigitalOutput');
configurePin(a, redLED, 'DigitalOutput');

% Data storage
tempVec = zeros(1, duration);
timeVec = 1:duration;

% Setup live plot
figure;
h = plot(timeVec, tempVec, 'b', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Temperature (°C)');
title('Live Cabin Temperature'); grid on;
ylim([10, 35]); xlim([0, duration]);

% Monitoring loop
for t = 1:duration
    V = readVoltage(a, sensorPin);
    T = (V - V0) / TC;       % °C
    tempVec(t) = T;

    % Update plot
    set(h, 'YData', tempVec);
    drawnow;

    % LED logic
    if T >= 18 && T <= 24
        % Green ON, others OFF
        writeDigitalPin(a, greenLED, 1);
        writeDigitalPin(a, yellowLED, 0);
        writeDigitalPin(a, redLED, 0);
        pause(1);
    elseif T < 18
        % Yellow blink every 0.5s
        writeDigitalPin(a, greenLED, 0);
        writeDigitalPin(a, redLED, 0);
        writeDigitalPin(a, yellowLED, 1); pause(0.5);
        writeDigitalPin(a, yellowLED, 0); pause(0.5);
    else
        % Red blink every 0.25s
        writeDigitalPin(a, greenLED, 0);
        writeDigitalPin(a, yellowLED, 0);
        writeDigitalPin(a, redLED, 1); pause(0.25);
        writeDigitalPin(a, redLED, 0); pause(0.25);
    end
end

% Cleanup (turn off all LEDs)
writeDigitalPin(a, greenLED, 0);
writeDigitalPin(a, yellowLED, 0);
writeDigitalPin(a, redLED, 0);
end