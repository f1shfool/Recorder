import React from 'react';

export const Card = ({ children, className }) => (
  <div className={`bg-white shadow rounded p-4 ${className}`}>
    {children}
  </div>
);

export const CardContent = ({ children }) => (
  <div className="p-4">
    {children}
  </div>
);

export const CardHeader = ({ children }) => (
  <div className="border-b px-4 py-2">
    {children}
  </div>
);

export const CardTitle = ({ children }) => (
  <h2 className="text-xl font-bold">
    {children}
  </h2>
);
