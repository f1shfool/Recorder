import React, { useState, useEffect } from 'react';
import { Button } from './components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/card';
import { Separator } from './components/ui/separator';
import { ScrollArea } from './components/ui/scroll-area';
import { Clock, Play, Square, Undo2, Eye, EyeOff, Trash2 } from 'lucide-react';

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
    <div className="p-4 max-w-4xl mx-auto">
      <div className="fixed top-4 left-4 text-xl font-bold bg-white p-2 rounded shadow z-10 flex items-center">
        <Clock className="mr-2" />
        {formatTime(currentTime)}
      </div>
      
      <Card className="mb-4 mt-16">
        <CardHeader>
          <CardTitle className="text-2xl">Activity Timer</CardTitle>
        </CardHeader>
        <CardContent>
          {!isRunning ? (
            <Button onClick={handleStart} size="lg" className="w-full py-6 text-xl">
              <Play className="mr-2" /> Start Activity
            </Button>
          ) : (
            <>
              <div className="grid grid-cols-4 gap-4 mb-6">
                {buttonPresses.map((presses, index) => (
                  <div key={index} className="flex flex-col space-y-2">
                    <Button 
                      onClick={() => handleButtonPress(index)}
                      size="lg"
                      className="py-8 text-xl"
                    >
                      {index + 1} ({presses.length})
                    </Button>
                    <Button 
                      onClick={() => handleUndo(index)}
                      disabled={presses.length === 0}
                      size="sm"
                      variant="destructive"
                      className="py-2"
                    >
                      <Undo2 className="mr-1" /> Undo
                    </Button>
                  </div>
                ))}
              </div>
              <Button onClick={handleEnd} size="lg" className="w-full py-6 text-xl" variant="destructive">
                <Square className="mr-2" /> End Activity
              </Button>
            </>
          )}
          <div className="mt-6 text-center text-xl font-semibold">
            Duration: {formatDuration(duration)}
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-between items-center mb-4">
        <Button onClick={() => setShowLog(!showLog)} size="lg" className="flex items-center">
          {showLog ? <EyeOff className="mr-2" /> : <Eye className="mr-2" />}
          {showLog ? 'Hide Log' : 'Show Log'}
        </Button>
        <Button onClick={handleClearLog} size="lg" variant="destructive" className="flex items-center">
          <Trash2 className="mr-2" /> Clear Log
        </Button>
      </div>

      {showLog && (
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl">Activity Log</CardTitle>
          </CardHeader>
          <CardContent>
            <ScrollArea className="h-[400px] pr-4">
              {logs.length === 0 ? (
                <div className="text-gray-500 text-center py-4">No logs available.</div>
              ) : (
                logs.map((log, index) => (
                  <div key={index} className="mb-6 p-4 border rounded shadow-sm">
                    <div className="grid grid-cols-2 gap-2 mb-2">
                      <div>
                        <span className="font-bold text-blue-600">Start:</span> {log.startTime}
                      </div>
                      <div>
                        <span className="font-bold text-blue-600">End:</span> {log.endTime}
                      </div>
                    </div>
                    <div className="mb-2">
                      <span className="font-bold text-blue-600">Duration:</span> {formatDuration(log.duration)}
                    </div>
                    <Separator className="my-2" />
                    <div className="font-bold text-lg text-blue-600 mb-2">Button Press Summary:</div>
                    {log.buttonPresses.map(({ button, count, presses }) => (
                      count > 0 && (
                        <div key={button} className="ml-4 mb-2">
                          <span className="font-semibold text-green-600">Button {button}:</span> 
                          <span className="ml-2">pressed at {presses.join(', ')}</span>
                          <span className="ml-2 font-semibold">Total: {count} times</span>
                        </div>
                      )
                    ))}
                  </div>
                ))
              )}
            </ScrollArea>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default ActivityTimer;