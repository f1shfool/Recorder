import React, { useState, useEffect } from 'react';
import Button from './components/ui/Button'; // Assuming this is a custom Button component
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/Card';

const ActivityTimer = () => {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [isRunning, setIsRunning] = useState(false);
  const [startTime, setStartTime] = useState(null);
  const [endTime, setEndTime] = useState(null);
  const [duration, setDuration] = useState(0);
  const [buttonPresses, setButtonPresses] = useState(Array(8).fill([]));
  const [logs, setLogs] = useState([]);
  const [showLog, setShowLog] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    let interval;
    if (isRunning) {
      interval = setInterval(() => {
        setDuration(prevDuration => prevDuration + 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isRunning]);

  const formatTime = (date) => {
    return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  };

  const formatDuration = (seconds) => {
    if (seconds < 60) return `${seconds} seconds`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)} minutes ${seconds % 60} seconds`;
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;
    return `${hours} hours ${minutes} minutes ${remainingSeconds} seconds`;
  };

  const handleStart = () => {
    setIsRunning(true);
    setStartTime(new Date());
    setEndTime(null);
    setDuration(0);
    setButtonPresses(Array(8).fill([]));
  };

  const handleEnd = () => {
    setIsRunning(false);
    const end = new Date();
    setEndTime(end);
    const log = {
      startTime: formatTime(startTime),
      endTime: formatTime(end),
      duration: duration,
      buttonPresses: buttonPresses.map((presses, index) => ({
        button: index + 1,
        count: presses.length,
        presses: presses
      })),
    };
    setLogs(prevLogs => [...prevLogs, log]);
  };

  const handleButtonPress = (index) => {
    setButtonPresses(prevPresses => {
      const newPresses = [...prevPresses];
      newPresses[index] = [...newPresses[index], formatTime(new Date())];
      return newPresses;
    });
  };

  const handleUndo = (index) => {
    setButtonPresses(prevPresses => {
      const newPresses = [...prevPresses];
      newPresses[index] = newPresses[index].slice(0, -1);
      return newPresses;
    });
  };

  const handleClearLog = () => {
    setLogs([]);
  };

  return (
    <div className="p-4">
      <div className="fixed top-4 left-4 text-xl font-bold bg-white p-2 rounded shadow z-10">
        {formatTime(currentTime)}
      </div>
      
      <Card className="mb-4 mt-12">
        <CardHeader>
          <CardTitle>Activity Timer</CardTitle>
        </CardHeader>
        <CardContent>
          {!isRunning ? (
            <Button onClick={handleStart} className="bg-green-500 hover:bg-green-600 text-white">
              Start
            </Button>
          ) : (
            <>
              <div className="grid grid-cols-4 gap-2 mb-4">
                {buttonPresses.map((presses, index) => (
                  <div key={index} className="flex flex-col">
                    <Button onClick={() => handleButtonPress(index)} className="bg-blue-500 hover:bg-blue-600 text-white">
                      {index + 1} ({presses.length})
                    </Button>
                    <Button 
                      onClick={() => handleUndo(index)}
                      disabled={presses.length === 0}
                      className="mt-1 bg-black hover:bg-red-600 text-white"
                    >
                      Undo
                    </Button>
                  </div>
                ))}
              </div>
              <Button onClick={handleEnd} className="bg-red-500 hover:bg-red-600 text-white">
                End
              </Button>
            </>
          )}
          <div className="mt-4">Duration: {formatDuration(duration)}</div>
        </CardContent>
      </Card>

      <div className="flex space-x-2">
        <Button onClick={() => setShowLog(!showLog)} className="bg-blue-500 hover:bg-blue-600 text-white">
          {showLog ? 'Hide Log' : 'Show Log'}
        </Button>
        <Button onClick={handleClearLog} className="bg-red-500 hover:bg-red-600 text-white">
          Clear Log
        </Button>
      </div>

      {showLog && (
        <Card className="mt-4">
          <CardHeader>
            <CardTitle>Activity Log</CardTitle>
          </CardHeader>
          <CardContent>
            {logs.length === 0 ? (
              <div className="text-gray-500">No logs available.</div>
            ) : (
              logs.map((log, index) => (
                <div key={index} className="mb-6 p-4 border rounded shadow-sm">
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <span className="font-bold text-blue-600">Start:</span> {log.startTime}
                    </div>
                    <div>
                      <span className="font-bold text-blue-600">End:</span> {log.endTime}
                    </div>
                  </div>
                  <div className="mt-2">
                    <span className="font-bold text-blue-600">Duration:</span> {formatDuration(log.duration)}
                  </div>
                  <div className="mt-4 font-bold text-lg text-blue-600">Button Press Summary:</div>
                  {log.buttonPresses.map(({ button, count, presses }) => (
                    count > 0 && (
                      <div key={button} className="ml-4 mt-2">
                        <span className="font-semibold text-green-600">Button {button}:</span> 
                        <span className="ml-2">pressed at {presses.join(', ')}</span>
                        <span className="ml-2 font-semibold">Total: {count} times</span>
                      </div>
                    )
                  ))}
                </div>
              ))
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default ActivityTimer;
