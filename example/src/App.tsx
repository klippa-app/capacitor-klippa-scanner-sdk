import React, { useState } from 'react';
import { KlippaScannerSDK } from "@klippa/capacitor-klippa-scanner-sdk"
import { KlippaScannerConfig } from './klippa-config'

const App: React.FC = () => {
    const [scannerResult, setScannerResult] = useState<string>('');

    const startSession = async () => {
        let sessionResultText = '';
        
        try {
            const result = await KlippaScannerSDK.getCameraResult(KlippaScannerConfig);
            sessionResultText = `Scan completed! ${result.images.length} image(s) captured`;
            console.log(result);
        } catch (error: any) {
            sessionResultText = 'Failed: ' + (error.message || error.toString());
        }

        setScannerResult(sessionResultText);
    };

    return (
        <div>
            <h1>Klippa Scanner SDK Example</h1>
            
            <button onClick={startSession}>
                Start Scanning
            </button>
            
            {scannerResult && (
                <div>
                    <h3>Result:</h3>
                    <p>{scannerResult}</p>
                </div>
            )}
        </div>
    );
};

export default App;
