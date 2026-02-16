import { IonApp, IonButton, IonContent, IonHeader, IonToolbar, IonTitle, IonText, setupIonicReact } from '@ionic/react';

import { KlippaScannerSDK } from "@klippa/capacitor-klippa-scanner-sdk"
import { KlippaScannerConfig } from './klippa-config'

/* Core CSS required for Ionic components to work properly */
import '@ionic/react/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/react/css/normalize.css';
import '@ionic/react/css/structure.css';
import '@ionic/react/css/typography.css';

/* Optional CSS utils that can be commented out */
import '@ionic/react/css/padding.css';
import '@ionic/react/css/float-elements.css';
import '@ionic/react/css/text-alignment.css';
import '@ionic/react/css/text-transformation.css';
import '@ionic/react/css/flex-utils.css';
import '@ionic/react/css/display.css';

/* Theme variables */
import './theme/variables.css';
import React, { useState } from 'react';

setupIonicReact();

const App: React.FC = () => {
    const [scannerResult, setScannerResult] = useState<string>('Unknown');

    const startSession = async () => {
        let sessionResultText = 'Unknown';
        
        try {
            const result = await KlippaScannerSDK.getCameraResult(KlippaScannerConfig);
            sessionResultText = 'Finished';
            console.log(result);
        } catch (error: any) {
            sessionResultText = 'Failed to start session: ' + (error.message || error.toString());
        }

        setScannerResult(sessionResultText);
    };

    return (
        <IonApp>
            <IonHeader>
                <IonToolbar>
                    <IonTitle>Plugin example app</IonTitle>
                </IonToolbar>
            </IonHeader>
            <IonContent className="ion-padding">
                <div style={{ 
                    display: 'flex', 
                    flexDirection: 'column', 
                    justifyContent: 'center', 
                    alignItems: 'center', 
                    height: '100%',
                    textAlign: 'center'
                }}>
                    <IonText>
                        <p>Scanner result: {scannerResult}</p>
                    </IonText>
                    
                    <IonButton 
                        expand="block" 
                        onClick={startSession}
                        style={{ marginTop: '20px', width: '200px' }}
                    >
                        Start Session
                    </IonButton>
                </div>
            </IonContent>
        </IonApp>
    );
};

export default App;
